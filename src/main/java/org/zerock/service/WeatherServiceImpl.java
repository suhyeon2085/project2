package org.zerock.service;

import java.io.StringReader;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;

import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.util.UriComponents;
import org.springframework.web.util.UriComponentsBuilder;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.NodeList;
import org.xml.sax.InputSource;
import org.zerock.domain.WeatherData;

import lombok.extern.log4j.Log4j;

@Log4j
@Service
public class WeatherServiceImpl implements WeatherService{

	private final String SERVICE_KEY = "Xs4ujx1%2F44NA9MMLqb%2B%2BajftbM3AjhwV%2FPhlSOqqOG%2BTDaUVmkJwmUgH3CHPbwMzaGOmWzcSr4LjcwZ6hsTf7Q%3D%3D";
	private final String API_URL = "https://apihub.kma.go.kr/api/typ02/openApi/VilageFcstInfoService_2.0/getVilageFcst";

	
	@Override
	public WeatherData getTodayWeather() {
		  try {
	            String baseDate = LocalDate.now().format(DateTimeFormatter.ofPattern("yyyyMMdd"));
	            String baseTime = "0500"; 
	            String nx = "128";
	            String ny = "35";

	            UriComponents uri = UriComponentsBuilder.fromHttpUrl(API_URL)
	                    .queryParam("serviceKey", SERVICE_KEY)
	                    .queryParam("numOfRows", 1000)
	                    .queryParam("pageNo", 1)
	                      .queryParam("base_date", baseDate)
	                    .queryParam("base_time", baseTime)
	                    .queryParam("nx", nx)
	                     .queryParam("ny", ny)
	                    .queryParam("dataType", "XML")
	                    .build(true); // true: 인코딩 안 함

	            RestTemplate restTemplate = new RestTemplate();
	            String xml = restTemplate.getForObject(uri.toUri(), String.class);
	            
	            log.info(restTemplate);

	            return extractWeatherDataFromXml(xml);

	        } catch (Exception e) {
	            e.printStackTrace();
	            return null;
	        }
	    }

	    // XML에서 원하는 항목만 추출
	    private WeatherData extractWeatherDataFromXml(String xml) throws Exception {
	        DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
	        DocumentBuilder builder = factory.newDocumentBuilder();
	        InputSource is = new InputSource(new StringReader(xml));
	        Document doc = builder.parse(is);

	        NodeList items = doc.getElementsByTagName("item");

	        WeatherData data = new WeatherData();

	        for (int i = 0; i < items.getLength(); i++) {
	            Element item = (Element) items.item(i);

	            String category = getTagValue("category", item);
	            String fcstValue = getTagValue("fcstValue", item);
	            String fcstDate = getTagValue("fcstDate", item);

	            data.setDay(fcstDate);

	            switch (category) {
	                case "PCP": if (data.getPrecipitation() == null) data.setPrecipitation(fcstValue); break;
	                case "WSD": if (data.getWindSpeed() == null) data.setWindSpeed(fcstValue); break;
	                case "VEC": if (data.getWindDirection() == null) data.setWindDirection(fcstValue); break;
	                case "TMX": data.setMaxTemperature(fcstValue); break;
	                case "TMN": data.setMinTemperature(fcstValue); break;
	            }
	        }

	        return data;
	    }

	    private String getTagValue(String tag, Element element) {
	        NodeList list = element.getElementsByTagName(tag);
	        if (list.getLength() > 0) {
	            return list.item(0).getTextContent();
	        }
	        return "";
	    }

}
