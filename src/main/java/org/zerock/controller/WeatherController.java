package org.zerock.controller;

import java.util.Arrays;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.client.RestTemplate;
import org.zerock.domain.WeatherData;
import org.zerock.service.WeatherService;

@Controller
public class WeatherController {
	
	// 날씨 관련 페이지 연결 
	/*@RequestMapping("/weather")
	public String main() {
		return "weather";
	}
	*/
	
	//날씨와 상관관계 페이지 연결
    @GetMapping("/correlation")
    public String showCorrelationPage() {
        return "correlation"; 
    }
    
    //지도 api
    @RequestMapping("/map")
    public String showMap() {
    	return "weather";
    }
    
    //파이썬에서 데이터 받아서 지도api에 삽입하는 컨트롤러
    //파이썬에서 어떻게 받느냐에 따라 url 수정 해야되고 getmapping 이름도 수정해야됌
    @GetMapping("/api/weather")
    @ResponseBody
    public List<WeatherData> getWeatherFromPython(){
    	RestTemplate restTemplate = new RestTemplate();
    	String url = "http://localhost:8080/api/weather";
    	
    	ResponseEntity<WeatherData[]> response =
    			restTemplate.getForEntity(url, WeatherData[].class);
    	
    	return Arrays.asList(response.getBody());
    	
    }
    
    //상관관계 그래프에서 기온 그래프로 가는 맵핑
    @GetMapping("/temperature")
    public String temperaturePage() {
        // temperature.jsp 같은 뷰 이름 리턴
        return "temperature";
    }
    
    //상관관계 그래프에서 풍속 그래프로 가는 맵핑
    @GetMapping("/windspeed")
    public String windspeedPage() {
        // temperature.jsp 같은 뷰 이름 리턴
        return "windspeed";
    }
    
    //상관관계 그래프에서 강수량 그래프로 가는 맵핑
    @GetMapping("/rainfall")
    public String rainfallPage() {
        // temperature.jsp 같은 뷰 이름 리턴
        return "rainfall";
    } 
    
    //날씨예 보 spi 사용하기 위한 맵핑 
  @Autowired
    private WeatherService weatherService;
     
    @GetMapping("/weather")
    public String showWeather(Model model) {
        WeatherData weather = weatherService.getTodayWeather();
        model.addAttribute("weather", weather);
        return "weather";
    }

    
    // 지도 발전량 데이터 가져와야되고 
    
    // -이거때매 서블릿 안됐음 

    
    
    // 봄 여름 가을 겨울 계절에 따라 다른 발전량 차이 그래프 가져오고 
    
    //오늘의 바람(풍향) 가져오고
    
    //오늘의 기압 (저/고) 가져오고
    
    //기온-발전량 상관관계 그래프 가져오고 - temperature.jsp에 연결
    
    //풍속-발전량 상관관계 그래프 가져오고 - windspeed.jsp에 연결
    
    //강수량-발전량 상관관계 그래프 가져오고 - rainfall.jsp에 연결
}
