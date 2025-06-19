
package org.zerock.domain;

import lombok.Data;

@Data
public class WeatherData {

	//나중에 필요한 데이터만 변수 지정해주자 
	private String region; //지역
	private double lat; //위도 
	private double lng; //경도
	private double power;
	
    // WeatherDay 내용 필드 추가
    private String baseDate;            // 요일 혹은 날짜 (예: "월", "2025-06-17")
    private String baseTime;  // 강수량 (%)
    private String category; // 최저기온
    private String fcstDate; // 최고기온
    private String fcstTime;      // 풍속 (m/s)
    private String fcstValue;  // 풍향 (예: 북동풍)
    private int nx;  // 풍향 (예: 북동풍)
    private int ny;  // 풍향 (예: 북동풍)
}
