package org.zerock.controller;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.http.converter.StringHttpMessageConverter;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.client.RestTemplate;
import org.zerock.domain.WindPowerDTO;

import java.net.URI;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

@Controller
public class WindPowerController {

    private final String SERVICE_KEY_ENCODED = "pFpj66B8XNos%2BA5g9TNorwHplOXQg%2B8zsBrvx8a%2BmeW%2BneNcPdkDPcp1WC3GP%2BhsjjuCzOexumuYap2jc28bBw%3D%3D";

    @GetMapping("/windpower")
    public String windPower(Model model) {
        List<WindPowerDTO> lastYearList = new ArrayList<>();
        List<WindPowerDTO> thisYearPredictedList = new ArrayList<>();

        try {
            String baseUrl = "http://apis.data.go.kr/B551893/wind-power-by-hour/list";
            int size = 100;
            ObjectMapper mapper = new ObjectMapper();
            RestTemplate restTemplate = new RestTemplate();
            restTemplate.getMessageConverters().add(0, new StringHttpMessageConverter(StandardCharsets.UTF_8));

            // 📌 전년도 데이터 (2023)
            String startLast = "20230101";
            String endLast = "20231231";
            getWindData(baseUrl, startLast, endLast, size, restTemplate, mapper, lastYearList);

            // 📌 올해 예측 데이터 (2024)
            String startThis = "20240101";
            String endThis = "20241231";
            getWindData(baseUrl, startThis, endThis, size, restTemplate, mapper, thisYearPredictedList);

        } catch (Exception e) {
            e.printStackTrace();
        }

        // JSON 변환 후 전달
        try {
            ObjectMapper mapper = new ObjectMapper();
            model.addAttribute("lastYearListJson", mapper.writeValueAsString(lastYearList));
            model.addAttribute("thisYearPredictedListJson", mapper.writeValueAsString(thisYearPredictedList));
        } catch (Exception e) {
            e.printStackTrace();
        }

        return "windpower";
    }
    
 
    

    private void getWindData(String baseUrl, String startD, String endD, int size,
                             RestTemplate restTemplate, ObjectMapper mapper, List<WindPowerDTO> resultList) throws Exception {
        int page = 1;
        boolean isLast = false;

        while (!isLast) {
            String url = baseUrl +
                    "?serviceKey=" + SERVICE_KEY_ENCODED +
                    "&startD=" + startD +
                    "&endD=" + endD +
                    "&resultType=json" +
                    "&size=" + size +
                    "&page=" + page;

            URI uri = new URI(url);
            String jsonResponse = restTemplate.getForObject(uri, String.class);
            JsonNode rootNode = mapper.readTree(jsonResponse);
            JsonNode bodyNode = rootNode.path("reponse").path("body");
            JsonNode contentArray = bodyNode.path("content");

            System.out.println("📄 페이지: " + page + " / 받은 개수: " + contentArray.size());
            
            if (contentArray.isArray()) {
                for (JsonNode node : contentArray) {
                    WindPowerDTO dto = mapper.treeToValue(node, WindPowerDTO.class);
                    resultList.add(dto);
                }
            }

            isLast = bodyNode.path("last").asBoolean(false);
            page++;
       }
    }
}