package org.zerock.controller;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.net.URI;
import java.nio.charset.StandardCharsets;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import javax.servlet.ServletContext;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.http.converter.StringHttpMessageConverter;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.client.RestTemplate;
import org.zerock.domain.WeatherData;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;

@Controller
public class WeatherController {

    // 공공데이터 API 키 및 기본 URL
    private final String SERVICE_KEY = "Xt2J5qiWMhBStQGBnIfZnX70IMyBPilFz%2FeQD2LhGZyAcW4M9W6gaqUKLSKLuPntOP9KrVT3SuVYmR%2Boo54PKw%3D%3D";
    private final String API_URL = "https://apis.data.go.kr/1360000/VilageFcstInfoService_2.0/getVilageFcst";

    // 메인 날씨 페이지 (정적 base_time으로 사용 중 - 0500)
    @GetMapping("/weather")
    public String showWeather(Model model) {
        List<WeatherData> weather = new ArrayList<>();
        try {
            String baseDate = LocalDate.now().format(DateTimeFormatter.ofPattern("yyyyMMdd"));
            String baseTime = "0500"; // 정적 시간 설정 (예시: 새벽 5시)
            String nx = "60";
            String ny = "127";

            String url = API_URL
                    + "?serviceKey=" + SERVICE_KEY
                    + "&pageNo=1"
                    + "&numOfRows=1000"
                    + "&base_date=" + baseDate
                    + "&base_time=" + baseTime
                    + "&nx=" + nx
                    + "&ny=" + ny
                    + "&dataType=json";

            RestTemplate restTemplate = new RestTemplate();
            restTemplate.getMessageConverters().add(0, new StringHttpMessageConverter(StandardCharsets.UTF_8));
            String response = restTemplate.getForObject(new URI(url), String.class);

            JsonNode items = new ObjectMapper()
                    .readTree(response)
                    .path("response").path("body").path("items").path("item");

            if (items.isArray()) {
                for (JsonNode item : items) {
                    weather.add(new ObjectMapper().treeToValue(item, WeatherData.class));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        model.addAttribute("weather", weather);
        return "weather";
    }

    // 클라이언트에서 nx, ny, baseTime을 받아 날씨 JSON 데이터를 반환 (JS에서 fetch용)
    @GetMapping("/weather/data")
    @ResponseBody
    public List<WeatherData> getWeatherByCoords(
            @RequestParam("nx") int nx,
            @RequestParam("ny") int ny,
            @RequestParam("baseTime") String baseTime
    ) {
        List<WeatherData> weather = new ArrayList<>();
        try {
            String baseDate = LocalDate.now().format(DateTimeFormatter.ofPattern("yyyyMMdd"));

            String url = API_URL
                    + "?serviceKey=" + SERVICE_KEY
                    + "&pageNo=1"
                    + "&numOfRows=1000"
                    + "&base_date=" + baseDate
                    + "&base_time=" + baseTime
                    + "&nx=" + nx
                    + "&ny=" + ny
                    + "&dataType=json";

            RestTemplate rt = new RestTemplate();
            rt.getMessageConverters().add(0, new StringHttpMessageConverter(StandardCharsets.UTF_8));
            String json = rt.getForObject(new URI(url), String.class);

            JsonNode items = new ObjectMapper()
                    .readTree(json)
                    .path("response").path("body").path("items").path("item");

            if (items.isArray()) {
                for (JsonNode node : items) {
                    weather.add(new ObjectMapper().treeToValue(node, WeatherData.class));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return weather;
    }
    
    //날짜 위도(lat), 경도(lng) 데이터를 갖고와서 json으로 변환시키는 컨트롤러
    @GetMapping("/weather/region")
    @ResponseBody
    public List<WeatherData> getWeatherDataForRegion(@RequestParam String region) throws IOException {
        List<WeatherData> weatherList = new ArrayList<>();

        // 리소스에서 CSV 파일 읽기 (예: resources/data/weather.csv)
        try (InputStream is = getClass().getResourceAsStream("/data/weather.csv");
             BufferedReader br = new BufferedReader(new InputStreamReader(is))) {

            String line = br.readLine(); // 헤더 스킵
            while ((line = br.readLine()) != null) {
                String[] tokens = line.split(",");
                if (tokens[0].equals(region)) {
                    WeatherData data = new WeatherData();
                    data.setADD(tokens[0]);
                    data.setLat(Double.parseDouble(tokens[1]));
                    data.setLng(Double.parseDouble(tokens[2]));
                    // 필요하면 나머지 정보도 set 가능
                    weatherList.add(data);
                }
            }
        }

        return weatherList;
    }


    // 상관관계 페이지 라우팅
    @GetMapping("/correlation")
    public String showCorrelationPage() {
        return "correlation";
    }

    // 지도 페이지 연결
    @GetMapping("/map")
    public String showMap() {
        return "weather";
    }

    // 강수량 상관관계 페이지
    @GetMapping("/rainfall")
    public String rainfallPage() {
        return "rainfall";
    }

    // Python 연동 데이터 받기 (API 예시)
    @GetMapping("/api/weather")
    @ResponseBody
    public List<WeatherData> getWeatherFromPython() {
        RestTemplate restTemplate = new RestTemplate();
        String url = "http://localhost:8080/api/weather";

        ResponseEntity<WeatherData[]> response =
                restTemplate.getForEntity(url, WeatherData[].class);

        return Arrays.asList(response.getBody());
    }
    

    // 풍향/풍속/날짜 json에서 데이터 가져오는 공통 메서드 추가
    private List<WeatherData> loadWeatherJson() {
        ObjectMapper mapper = new ObjectMapper();

        try (InputStream is = getClass().getResourceAsStream("/Data/dongbuk_data.json")) {
        	
            if (is == null) {
                System.out.println("❌ JSON 파일 없음");
                return null;
            }

            List<WeatherData> data = mapper.readValue(is, new TypeReference<List<WeatherData>>() {});
            
            System.out.println("✅ 데이터 수: " + data.size());

            for (WeatherData wd : data) {
                System.out.println("날짜: " + wd.getDate() + ", 발전량: " + wd.getPower());
            }
            
            return data;
        } catch (IOException e) {
            e.printStackTrace();
            return null;
        }
        
    }
    
    //풍향 jsp로 맵핑( json 데이터를 받은걸loadWeatherJson() 여기에 뿌려준다는 것 )
    @RequestMapping("/temperature")
    public String showTemperature(Model model) {
        List<WeatherData> list = loadWeatherJson();
        
        // JSON 문자열로 변환해서 전달
        ObjectMapper mapper = new ObjectMapper();
        try {
            String jsonString = mapper.writeValueAsString(list);
            model.addAttribute("dataListJson", jsonString);  
        } catch (IOException e) {
            e.printStackTrace();
            model.addAttribute("dataListJson", "[]");
        }

        return "temperature";
    }
    //풍속 jsp로 맵핑( json 데이터를 받은걸loadWeatherJson() 여기에 뿌려준다는 것 )
    @RequestMapping("/windspeed")
    public String showWindspeed(Model model) {
        List<WeatherData> list = loadWeatherJson();
        
        ObjectMapper mapper = new ObjectMapper();
        try {
            String jsonString = mapper.writeValueAsString(list);
            model.addAttribute("dataListJson", jsonString);  
        } catch (IOException e) {
            e.printStackTrace();
            model.addAttribute("dataListJson", "[]");
        }

        return "windspeed";
    }

    


}
