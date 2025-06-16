
package org.zerock.domain;

import lombok.Data;

@Data
public class WeatherData {

	//나중에 필요한 데이터만 변수 지정해주자 
	private String region; //지역
	private double lat; //위도 
	private double lng; //경도
	private double power;
	
}
