//package org.zerock.service;
//
//import java.net.URLDecoder;
//import java.nio.charset.StandardCharsets;
//import java.time.LocalDate;
//import java.time.format.DateTimeFormatter;
//import java.net.URLEncoder;
//
//import org.springframework.stereotype.Service;
//import org.springframework.web.client.RestTemplate;
//import org.springframework.web.util.UriComponents;
//import org.springframework.web.util.UriComponentsBuilder;
//import org.zerock.domain.WeatherData;
//
//import com.fasterxml.jackson.databind.JsonNode;
//import com.fasterxml.jackson.databind.ObjectMapper;
//
//import lombok.extern.log4j.Log4j;
//
//@Log4j
//@Service
//public class WeatherServiceImpl implements WeatherService {
//
//	private final String SERVICE_KEY = "Xt2J5qiWMhBStQGBnIfZnX70IMyBPilFz%2FeQD2LhGZyAcW4M9W6gaqUKLSKLuPntOP9KrVT3SuVYmR%2Boo54PKw%3D%3D";
//	private final String API_URL = "http://apis.data.go.kr/1360000/VilageFcstInfoService_2.0/getVilageFcst";
//
//	@Override
//	public WeatherData getTodayWeather() {
//	    try {
//	        
//	        String baseDate = LocalDate.now().format(DateTimeFormatter.ofPattern("yyyyMMdd"));
//	        String baseTime = "0500";
//	        String nx = "60";
//	        String ny = "127";
//
//	        // UriComponentsBuilder를 통해서 쿼리 파라미터 조립
//	        UriComponents uri = UriComponentsBuilder.fromHttpUrl(API_URL)
//	                .queryParam("serviceKey", SERVICE_KEY)  // 인코딩된 키 그대로 넣기
//	                .queryParam("numOfRows", 1000)
//	                .queryParam("pageNo", 1)
//	                .queryParam("base_date", baseDate)
//	                .queryParam("base_time", baseTime)
//	                .queryParam("nx", nx)
//	                .queryParam("ny", ny)
//	                .queryParam("dataType", "json")           // 여기는 _type이니까 API 문서대로 넣기
//	                .build(false);  // 이미 인코딩된 파라미터가 있으면 false로 설정
//
//	        RestTemplate restTemplate = new RestTemplate();
//	        String json = restTemplate.getForObject(uri.toUri(), String.class);
//	        
//	        System.out.println(json);
//	        log.info(json);
//
//	        return extractWeatherDataFromJson(json);
//
//	    } catch (Exception e) {
//	        e.printStackTrace();
//	        return null;
//	    }
//	}
//
//    // JSON 응답에서 데이터 추출
//    private WeatherData extractWeatherDataFromJson(String json) throws Exception {
//        ObjectMapper mapper = new ObjectMapper();
//        JsonNode root = mapper.readTree(json);
//
//        // JSON 구조에 따라 조정 필요 (예: response -> body -> items)
//        JsonNode items = root.path("response").path("body").path("items").path("item");
//
//        WeatherData data = new WeatherData();
//
//        for (JsonNode item : items) {
//            String category = item.path("category").asText();
//            String fcstValue = item.path("fcstValue").asText();
//            String fcstDate = item.path("fcstDate").asText();
//
//            data.setDay(fcstDate);
//
//            switch (category) {
//                case "PCP":
//                    if (data.getPrecipitation() == null) data.setPrecipitation(fcstValue);
//                    break;
//                case "WSD":
//                    if (data.getWindSpeed() == null) data.setWindSpeed(fcstValue);
//                    break;
//                case "VEC":
//                    if (data.getWindDirection() == null) data.setWindDirection(fcstValue);
//                    break;
//                case "TMX":
//                    data.setMaxTemperature(fcstValue);
//                    break;
//                case "TMN":
//                    data.setMinTemperature(fcstValue);
//                    break;
//            }
//        }
//        return data;
//    }
//}
