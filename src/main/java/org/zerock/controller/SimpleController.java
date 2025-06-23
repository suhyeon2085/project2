package org.zerock.controller;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.extern.slf4j.Slf4j;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.converter.StringHttpMessageConverter;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.client.RestTemplate;
import org.zerock.domain.WindPowerDTO;
import org.zerock.service.WindDataService;

import java.net.URI;
import java.nio.charset.StandardCharsets;
import java.time.YearMonth;
import java.util.*;

@Slf4j
@Controller
public class SimpleController {

    private static final String SERVICE_KEY = "pFpj66B8XNos%2BA5g9TNorwHplOXQg%2B8zsBrvx8a%2BmeW%2BneNcPdkDPcp1WC3GP%2BhsjjuCzOexumuYap2jc28bBw%3D%3D";
    private static final String BASE_URL = "https://apis.data.go.kr/B551893/wind-power-by-hour/list";

    @Autowired
    private WindDataService windDataService;

    @GetMapping("/wind")
    public String showYearlyAverage(
            @RequestParam(value = "year", required = false) String year,
            @RequestParam(value = "targetKey", required = false, defaultValue = "전체") String targetKey,
            Model model) {

        if (year == null || year.isEmpty()) {
            year = "2025";
        }

        RestTemplate restTemplate = new RestTemplate();
        restTemplate.getMessageConverters().add(0, new StringHttpMessageConverter(StandardCharsets.UTF_8));
        ObjectMapper mapper = new ObjectMapper();

        Map<String, List<List<Double>>> rawMap = new HashMap<>();
        Map<String, Map<Integer, List<List<Double>>>> monthlyRawMap = new HashMap<>();

        // 1) 날짜 유효성 체크 포함 연도별 데이터 수집
        for (int month = 1; month <= 12; month++) {
            int maxDay = YearMonth.of(Integer.parseInt(year), month).lengthOfMonth();

            for (int day = 1; day <= maxDay; day++) {
                String date = String.format("%s%02d%02d", year, month, day);

                for (int page = 1; page <= 3; page++) {
                    try {
                        URI uri = new URI(BASE_URL +
                                "?serviceKey=" + SERVICE_KEY +
                                "&page=" + page +
                                "&size=100" +
                                "&startD=" + date +
                                "&endD=" + date);

                        String response = restTemplate.getForObject(uri, String.class);

                        if (response == null || !response.trim().startsWith("{")) {
                            log.warn("비정상 응답: {} (date={}, page={})", response, date, page);
                            break;
                        }

                        JsonNode contentList = mapper.readTree(response)
                                .path("reponse").path("body").path("content");

                        if (contentList.isArray()) {
                            for (JsonNode item : contentList) {
                                String ipptNam = item.path("ipptNam").asText();
                                String hogi = item.path("hogi").asText();
                                String key = ipptNam + "(" + hogi + ")";

                                List<Double> hourlyList = new ArrayList<>();
                                for (int i = 1; i <= 24; i++) {
                                    hourlyList.add(item.path(String.format("qhorGen%02d", i)).asDouble(0.0));
                                }

                                // 원본 rawMap 저장
                                rawMap.computeIfAbsent(key, k -> new ArrayList<>()).add(hourlyList);

                                // 월별 데이터 저장
                                monthlyRawMap
                                        .computeIfAbsent(key, k -> new HashMap<>())
                                        .computeIfAbsent(month, m -> new ArrayList<>())
                                        .add(hourlyList);

                                // 전체도 저장
                                monthlyRawMap
                                        .computeIfAbsent("전체", k -> new HashMap<>())
                                        .computeIfAbsent(month, m -> new ArrayList<>())
                                        .add(hourlyList);

                                // 전체 rawMap에도 저장
                                rawMap.computeIfAbsent("전체", k -> new ArrayList<>()).add(hourlyList);
                            }
                        }

                    } catch (Exception e) {
                        log.warn("데이터 수집 오류 - 날짜: {}, page: {}", date, page, e);
                    }
                }
            }
        }

        // 2) 시간대별 평균 계산
        Map<String, List<Double>> avgMap = new LinkedHashMap<>();
        List<Double> totalAvg = new ArrayList<>(Collections.nCopies(24, 0.0));
        int totalCount = 0;

        for (Map.Entry<String, List<List<Double>>> entry : rawMap.entrySet()) {
            String key = entry.getKey();
            List<List<Double>> dataLists = entry.getValue();

            List<Double> avgList = new ArrayList<>(Collections.nCopies(24, 0.0));
            for (List<Double> list : dataLists) {
                for (int i = 0; i < 24; i++) {
                    avgList.set(i, avgList.get(i) + list.get(i));
                    totalAvg.set(i, totalAvg.get(i) + list.get(i));
                }
            }
            for (int i = 0; i < 24; i++) {
                avgList.set(i, avgList.get(i) / dataLists.size());
            }

            avgMap.put(key, avgList);
            totalCount += dataLists.size();
        }

        for (int i = 0; i < 24; i++) {
            if (totalCount > 0) {
                totalAvg.set(i, totalAvg.get(i) / totalCount);
            }
        }

        // 3) 고정 기준 평균 (2022.01.01 ~ 2025.05.31) 시간대별 계산
        List<Double> fixedAvg = new ArrayList<>(Collections.nCopies(24, 0.0));
        int fixedCount = 0;

        for (int page = 1; page <= 30; page++) {
            try {
                URI uri = new URI(BASE_URL +
                        "?serviceKey=" + SERVICE_KEY +
                        "&page=" + page +
                        "&size=100" +
                        "&startD=20220101" +
                        "&endD=20250531");

                String response = restTemplate.getForObject(uri, String.class);
                JsonNode contentList = mapper.readTree(response)
                        .path("reponse").path("body").path("content");

                if (contentList.isArray()) {
                    for (JsonNode item : contentList) {
                        for (int i = 1; i <= 24; i++) {
                            double val = item.path(String.format("qhorGen%02d", i)).asDouble(0.0);
                            fixedAvg.set(i - 1, fixedAvg.get(i - 1) + val);
                        }
                        fixedCount++;
                    }
                }

            } catch (Exception e) {
                log.warn("고정 기준 평균 데이터 오류 page: {}", page, e);
            }
        }

        for (int i = 0; i < 24; i++) {
            if (fixedCount > 0) {
                fixedAvg.set(i, fixedAvg.get(i) / fixedCount);
            }
        }

        // 4) 월별 평균 계산 (조회년도)
        Map<String, List<Double>> monthlyAvgMap = new LinkedHashMap<>();

        for (Map.Entry<String, Map<Integer, List<List<Double>>>> entry : monthlyRawMap.entrySet()) {
            String key = entry.getKey();
            Map<Integer, List<List<Double>>> monthMap = entry.getValue();

            List<Double> monthlyAverages = new ArrayList<>();
            for (int m = 1; m <= 12; m++) {
                List<List<Double>> dayLists = monthMap.getOrDefault(m, Collections.emptyList());

                double sum = 0;
                int count = 0;
                for (List<Double> hours : dayLists) {
                    for (double val : hours) {
                        sum += val;
                    }
                    count++;
                }

                double avg = count > 0 ? sum / count : 0;
                monthlyAverages.add(avg);
            }
            monthlyAvgMap.put(key, monthlyAverages);
        }

        // 5) 고정 기준 월별 평균 계산 (20220101~20250531)
        Map<String, Map<Integer, List<List<Double>>>> monthlyRawMapFixed = new HashMap<>();
        for (int page = 1; page <= 30; page++) {
            try {
                URI uri = new URI(BASE_URL +
                        "?serviceKey=" + SERVICE_KEY +
                        "&page=" + page +
                        "&size=100" +
                        "&startD=20220101" +
                        "&endD=20250531");

                String response = restTemplate.getForObject(uri, String.class);
                JsonNode contentList = mapper.readTree(response)
                        .path("reponse").path("body").path("content");

                if (contentList.isArray()) {
                    for (JsonNode item : contentList) {
                        String ipptNam = item.path("ipptNam").asText();
                        String hogi = item.path("hogi").asText();
                        String key = ipptNam + "(" + hogi + ")";

                        List<Double> hourlyList = new ArrayList<>();
                        for (int i = 1; i <= 24; i++) {
                            hourlyList.add(item.path(String.format("qhorGen%02d", i)).asDouble(0.0));
                        }

                        String dgenYmd = item.path("dgenYmd").asText();
                        int month = 1;
                        try {
                            month = Integer.parseInt(dgenYmd.substring(4, 6));
                        } catch (Exception ignored) {}

                        monthlyRawMapFixed
                                .computeIfAbsent(key, k -> new HashMap<>())
                                .computeIfAbsent(month, m -> new ArrayList<>())
                                .add(hourlyList);

                        monthlyRawMapFixed
                                .computeIfAbsent("전체", k -> new HashMap<>())
                                .computeIfAbsent(month, m -> new ArrayList<>())
                                .add(hourlyList);
                    }
                }
            } catch (Exception e) {
                log.warn("고정 기준 월별 데이터 오류 page: {}", page, e);
            }
        }

        Map<String, List<Double>> fixedMonthlyAvg = new LinkedHashMap<>();
        for (Map.Entry<String, Map<Integer, List<List<Double>>>> entry : monthlyRawMapFixed.entrySet()) {
            String key = entry.getKey();
            Map<Integer, List<List<Double>>> monthMap = entry.getValue();

            List<Double> monthlyAverages = new ArrayList<>();
            for (int m = 1; m <= 12; m++) {
                List<List<Double>> dayLists = monthMap.getOrDefault(m, Collections.emptyList());

                double sum = 0;
                int count = 0;
                for (List<Double> hours : dayLists) {
                    for (double val : hours) {
                        sum += val;
                    }
                    count++;
                }
                double avg = count > 0 ? sum / count : 0;
                monthlyAverages.add(avg);
            }
            fixedMonthlyAvg.put(key, monthlyAverages);
        }

        // 6) Model에 데이터 전달
        model.addAttribute("targetYear", year);
        model.addAttribute("targetKey", targetKey);
        model.addAttribute("avgMap", avgMap);
        model.addAttribute("totalAvg", totalAvg);
        model.addAttribute("fixedAvg", fixedAvg);
        model.addAttribute("monthlyAvgMap", monthlyAvgMap);
        model.addAttribute("fixedMonthlyAvg", fixedMonthlyAvg);

        return "simpleWind";
    }

    // JSON 수집 후 저장 API 호출
    @GetMapping("/wind/fetchAll")
    @ResponseBody
    public String fetchAndSaveWindData() {
        int count = windDataService.fetchAndSaveAllWindData();
        if (count > 0) {
            return "✅ 저장 완료! 총 수집된 항목 수: " + count;
        } else {
            return "❌ 저장 실패 또는 0건";
        }
    }

    // 저장된 JSON 불러와서 DB 저장 API 호출
    @GetMapping("/wind/loadJsonToDb")
    @ResponseBody
    public String loadJsonAndSaveToDb() {
        try {
            List<WindPowerDTO> list = windDataService.loadWindDataFromJsonFile("C:/wind_data/wind_data_20220101_20250531.json");
            windDataService.saveAll(list);
            return "✅ DB 저장 완료: " + list.size() + "건";
        } catch (Exception e) {
            log.error("DB 저장 실패", e);
            return "❌ 오류 발생: " + e.getMessage();
        }
    }

    // DB에서 연도별 데이터 조회 후 JSP 렌더링
    @GetMapping("/wind/fromDb")
    public String showGraphFromDb(@RequestParam(value = "year", required = false) String year, Model model) {
        if (year == null || year.isEmpty()) {
            year = "2025";
        }

        List<WindPowerDTO> list = windDataService.getDataByYear(year);

        Map<String, List<List<Double>>> rawMap = new HashMap<>();
        Map<String, Map<Integer, List<List<Double>>>> monthlyRawMap = new HashMap<>();

        for (WindPowerDTO dto : list) {
            String key = dto.getIpptNam() + "(" + dto.getHogi() + ")";

            List<Double> hourlyList = Arrays.asList(
                    dto.getQhorGen01(), dto.getQhorGen02(), dto.getQhorGen03(), dto.getQhorGen04(),
                    dto.getQhorGen05(), dto.getQhorGen06(), dto.getQhorGen07(), dto.getQhorGen08(),
                    dto.getQhorGen09(), dto.getQhorGen10(), dto.getQhorGen11(), dto.getQhorGen12(),
                    dto.getQhorGen13(), dto.getQhorGen14(), dto.getQhorGen15(), dto.getQhorGen16(),
                    dto.getQhorGen17(), dto.getQhorGen18(), dto.getQhorGen19(), dto.getQhorGen20(),
                    dto.getQhorGen21(), dto.getQhorGen22(), dto.getQhorGen23(), dto.getQhorGen24()
            );

            rawMap.computeIfAbsent(key, k -> new ArrayList<>()).add(hourlyList);

            int month = 1;
            try {
                month = Integer.parseInt(dto.getDgenYmd().substring(4, 6));
            } catch (Exception ignored) {}

            monthlyRawMap
                    .computeIfAbsent(key, k -> new HashMap<>())
                    .computeIfAbsent(month, m -> new ArrayList<>())
                    .add(hourlyList);

            monthlyRawMap
                    .computeIfAbsent("전체", k -> new HashMap<>())
                    .computeIfAbsent(month, m -> new ArrayList<>())
                    .add(hourlyList);

            rawMap.computeIfAbsent("전체", k -> new ArrayList<>()).add(hourlyList);
        }

        Map<String, List<Double>> avgMap = new LinkedHashMap<>();
        List<Double> totalAvg = new ArrayList<>(Collections.nCopies(24, 0.0));
        int totalCount = 0;

        for (Map.Entry<String, List<List<Double>>> entry : rawMap.entrySet()) {
            String key = entry.getKey();
            List<List<Double>> dataLists = entry.getValue();

            List<Double> avgList = new ArrayList<>(Collections.nCopies(24, 0.0));
            for (List<Double> hourlyValues : dataLists) {
                for (int i = 0; i < 24; i++) {
                    avgList.set(i, avgList.get(i) + hourlyValues.get(i));
                    totalAvg.set(i, totalAvg.get(i) + hourlyValues.get(i));
                }
            }
            for (int i = 0; i < 24; i++) {
                avgList.set(i, avgList.get(i) / dataLists.size());
            }

            avgMap.put(key, avgList);
            totalCount += dataLists.size();
        }

        for (int i = 0; i < 24; i++) {
            if (totalCount > 0) {
                totalAvg.set(i, totalAvg.get(i) / totalCount);
            }
        }

        model.addAttribute("targetYear", year);
        model.addAttribute("avgMap", avgMap);
        model.addAttribute("totalAvg", totalAvg);
        model.addAttribute("monthlyAvgMap", monthlyRawMap);

        return "simpleWind";
    }

    // 테스트용 API들 (fetch, loadJson, saveDb, loadDb)
    @GetMapping("/wind/test/fetch")
    @ResponseBody
    public String testFetchAndSaveJson() {
        int count = windDataService.fetchAndSaveAllWindData();
        return "API 데이터 수집 및 JSON 저장 완료! 저장된 데이터 수: " + count;
    }

    @GetMapping("/wind/test/loadJson")
    @ResponseBody
    public String testLoadJsonToDto() {
        try {
            List<WindPowerDTO> list = windDataService.loadWindDataFromJsonFile("C:/wind_data/wind_data_20220101_20250531.json");
            return "JSON 파일 읽기 성공! DTO 개수: " + list.size();
        } catch (Exception e) {
            return "JSON 파일 읽기 실패: " + e.getMessage();
        }
    }

    @GetMapping("/wind/test/saveDb")
    @ResponseBody
    public String testSaveDtoToDb() {
        try {
            List<WindPowerDTO> list = windDataService.loadWindDataFromJsonFile("C:/wind_data/wind_data_20220101_20250531.json");
            windDataService.saveAll(list);
            return "DB 저장 완료! 저장된 DTO 개수: " + list.size();
        } catch (Exception e) {
            return "DB 저장 실패: " + e.getMessage();
        }
    }

    @GetMapping("/wind/test/loadDb")
    @ResponseBody
    public String testLoadFromDb(@RequestParam(defaultValue = "2025") String year) {
        try {
            List<WindPowerDTO> list = windDataService.getDataByYear(year);
            return year + "년도 DB 조회 완료! 데이터 수: " + list.size();
        } catch (Exception e) {
            return "DB 조회 실패: " + e.getMessage();
        }
    }
}