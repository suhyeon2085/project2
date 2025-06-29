
package org.zerock.domain;

import com.fasterxml.jackson.annotation.JsonProperty;

import lombok.Data;

@Data
public class WeatherData {

	//필요한 데이터만 변수 지정
	private String region; //지역
	private int nx; 
    private int ny;  
    
    private double CAP;		//용량
    private String PLANT;	//단지명
    private String ADD;		//주소
	private double lat; 	//위도 
	private double lng; 	//경도

    // WeatherDay 내용 필드 추가
    private String baseDate;   // 요일 혹은 날짜 (예: "월", "2025-06-17")
    private String baseTime;  // 강수량 (%)
    private String category; // 최저기온
    private String fcstDate; // 최고기온
    private String fcstTime;      // 풍속 (m/s)
    private String fcstValue;  // 풍향 (예: 북동풍)
    
    
    //json 데이터 가져오는 변수 지정
    @JsonProperty("date")
    private String date;   //날짜
    @JsonProperty("power")
    private double power;  //발전량
    @JsonProperty("windDirection")
    private double windDirection; // 최대 순간 풍속 & 풍향
    @JsonProperty("wind")
    private double wind; 	//평균 풍속 

}
