package org.zerock.controller;

import java.util.Map;

import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.client.RestTemplate;

import com.fasterxml.jackson.databind.ObjectMapper;

@Controller
public class ViewController {

    @GetMapping("/powerChart")
    public String powerChart(Model model) throws Exception {
        String apiUrl = "http://192.168.30.232:8000/pyapi";

        RestTemplate restTemplate = new RestTemplate();
        ResponseEntity<Map> response = restTemplate.getForEntity(apiUrl, Map.class);
        Map<String, Object> body = response.getBody();

        ObjectMapper mapper = new ObjectMapper();

        // 영흥풍력1호기
        model.addAttribute("list_9997", body.get("list_9997"));
        model.addAttribute("pred_9997", body.get("pred_9997"));
        model.addAttribute("aver_9997", body.get("aver_9997"));

        // 영흥풍력2호기
        model.addAttribute("list_9998", body.get("list_9998"));
        model.addAttribute("pred_9998", body.get("pred_9998"));
        model.addAttribute("aver_9998", body.get("aver_9998"));

        // 군위화산풍력
        model.addAttribute("list_D001", body.get("list_D001"));
        model.addAttribute("pred_D001", body.get("pred_D001"));
        model.addAttribute("aver_D001", body.get("aver_D001"));

        return "powerChart"; // /WEB-INF/views/powerChart.jsp
    }
}