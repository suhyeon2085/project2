package org.zerock.service;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.extern.slf4j.Slf4j;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.converter.StringHttpMessageConverter;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.client.RestTemplate;
import org.zerock.domain.WindPowerDTO;
import org.zerock.mapper.WindPowerMapper;

import java.io.File;
import java.io.IOException;
import java.net.URI;
import java.nio.charset.StandardCharsets;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;

@Slf4j
@Service
public class WindDataService {

    private static final String SERVICE_KEY = "pFpj66B8XNos%2BA5g9TNorwHplOXQg%2B8zsBrvx8a%2BmeW%2BneNcPdkDPcp1WC3GP%2BhsjjuCzOexumuYap2jc28bBw%3D%3D";
    private static final String BASE_URL = "https://apis.data.go.kr/B551893/wind-power-by-hour/list";
    private static final DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyyMMdd");

    private final RestTemplate restTemplate;
    private final ObjectMapper mapper;

    @Autowired
    private WindPowerMapper windPowerMapper;

    public WindDataService() {
        this.restTemplate = new RestTemplate();
        this.restTemplate.getMessageConverters().add(0, new StringHttpMessageConverter(StandardCharsets.UTF_8));
        this.mapper = new ObjectMapper();
    }

    // 1) API 호출해서 JSON 파일로 저장
    public int fetchAndSaveAllWindData() {
        List<JsonNode> allData = new ArrayList<>();
        LocalDate start = LocalDate.of(2022, 1, 1);
        LocalDate end = LocalDate.of(2025, 5, 31);

        for (LocalDate date = start; !date.isAfter(end); date = date.plusDays(1)) {
            String dateStr = date.format(formatter);

            for (int page = 1; page <= 3; page++) {
                try {
                    String url = BASE_URL +
                            "?serviceKey=" + SERVICE_KEY +
                            "&page=" + page +
                            "&size=100" +
                            "&startD=" + dateStr +
                            "&endD=" + dateStr;

                    URI uri = new URI(url);

                    String response = restTemplate.getForObject(uri, String.class);

                    if (response == null || !response.trim().startsWith("{")) {
                        log.warn("비정상 응답: {} (date={}, page={})", response, dateStr, page);
                        break;
                    }

                    JsonNode content = mapper.readTree(response)
                            .path("reponse")   // 오타 주의: reponse
                            .path("body")
                            .path("content");

                    if (content.isArray()) {
                        if (content.size() == 0) break;  // 더 이상 데이터 없으면 break 페이지 루프

                        for (JsonNode node : content) {
                            allData.add(node);
                        }
                    } else {
                        break; // content가 배열이 아니면 break
                    }

                    Thread.sleep(300); // API 호출 제한 대응

                } catch (Exception e) {
                    log.warn("에러 발생: {} (date={}, page={})", e.toString(), dateStr, page);
                    // e.printStackTrace(); // 필요시 스택 트레이스 찍기
                }
            }
        }

        try {
            File output = new File("C:/wind_data/wind_data_20220101_20250531.json");
            output.getParentFile().mkdirs();
            mapper.writerWithDefaultPrettyPrinter().writeValue(output, allData);
            log.info("✅ 데이터 저장 완료: {}건", allData.size());
        } catch (IOException e) {
            log.error("파일 저장 실패", e);
            return -1;
        }

        return allData.size();
    }

    // 2) JSON 파일 읽어서 List<WindPowerDTO> 반환
    public List<WindPowerDTO> loadWindDataFromJsonFile(String filePath) throws IOException {
        File jsonFile = new File(filePath);
        JsonNode rootNode = mapper.readTree(jsonFile);
        JsonNode contentNode = rootNode.path("reponse").path("body").path("content");

        return mapper.readValue(
                contentNode.traverse(),
                new TypeReference<List<WindPowerDTO>>() {}
        );
    }

    // 3) DB에 데이터 저장 (트랜잭션 처리)
    @Transactional
    public void saveAll(List<WindPowerDTO> list) {
        for (WindPowerDTO dto : list) {
            windPowerMapper.insertWindPower(dto);
        }
    }

    // 4) DB에서 연도별 데이터 조회
    public List<WindPowerDTO> getDataByYear(String year) {
        return windPowerMapper.findByYear(year);
    }
}