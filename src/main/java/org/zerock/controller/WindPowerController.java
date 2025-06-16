package org.zerock.controller;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.client.RestTemplate;
import org.zerock.domain.WindPowerDTO;

import java.util.ArrayList;
import java.util.List;

@Controller
public class WindPowerController {

    private final String SERVICE_KEY_ENCODED = "pFpj66B8XNos%2BA5g9TNorwHplOXQg%2B8zsBrvx8a%2BmeW%2BneNcPdkDPcp1WC3GP%2BhsjjuCzOexumuYap2jc28bBw%3D%3D";

    @GetMapping("/windpower")
    public String windPower(Model model) {

        List<WindPowerDTO> windList = new ArrayList<>();

        try {
//        	String url = "https://apis.data.go.kr/B551893/wind-power-by-hour/list?serviceKey=pFpj66B8XNos%2BA5g9TNorwHplOXQg%2B8zsBrvx8a%2BmeW%2BneNcPdkDPcp1WC3GP%2BhsjjuCzOexumuYap2jc28bBw%3D%3D&startD=20220101&endD=20220131";
	           String url = "http://apis.data.go.kr/B551893/wind-power-by-hour/list" +
	                    "?serviceKey=" + SERVICE_KEY_ENCODED +
	                    "&startD=20220101" +
	                    "&endD=2021231" +
	                    "&resultType=json";

            System.out.println("요청 URL: " + url);

            // 1. API 요청 후 String으로 응답 받기
            RestTemplate restTemplate = new RestTemplate();
            String jsonResponse = restTemplate.getForObject(url, String.class);
            System.out.println("API 응답 JSON: " + jsonResponse);

            // 2. JSON 파싱
            ObjectMapper mapper = new ObjectMapper();
            JsonNode rootNode = mapper.readTree(jsonResponse);

            JsonNode contentArray = rootNode.path("response").path("body").path("content");

            System.out.println("데이터 개수: " + contentArray.size());

            if (contentArray.isArray()) {
                for (JsonNode node : contentArray) {
                    WindPowerDTO dto = mapper.treeToValue(node, WindPowerDTO.class);
                    windList.add(dto);
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        model.addAttribute("windList", windList);
        return "windpower";
    }
}