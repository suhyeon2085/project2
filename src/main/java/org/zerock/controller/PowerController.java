package org.zerock.controller;

import java.util.*;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class PowerController {

    @GetMapping("/dashboard")
    public String dashboard(Model model) {

        // 1) 월별 전체 발전량 데이터 (전년 실제 vs 올해 예측)
        Map<String, Integer> lastYearActual = new LinkedHashMap<>();
        Map<String, Integer> thisYearForecast = new LinkedHashMap<>();
        for (int month = 1; month <= 12; month++) {
            String lastYearKey = String.format("2023%02d", month);
            String thisYearKey = String.format("2024%02d", month);
            lastYearActual.put(lastYearKey, 500 + (int)(Math.random() * 200));
            thisYearForecast.put(thisYearKey, 600 + (int)(Math.random() * 200));
        }

        // 2) 발전소별 실제 vs 예측 발전량 (월별 합계)
        List<String> plants = Arrays.asList("발전소 A", "발전소 B", "발전소 C");
        Map<String, List<Integer>> plantActual = new LinkedHashMap<>();
        Map<String, List<Integer>> plantForecast = new LinkedHashMap<>();

        for (String plant : plants) {
            List<Integer> actualList = new ArrayList<>();
            List<Integer> forecastList = new ArrayList<>();
            for (int i = 0; i < 12; i++) {
                actualList.add(300 + (int)(Math.random() * 100));
                forecastList.add(350 + (int)(Math.random() * 100));
            }
            plantActual.put(plant, actualList);
            plantForecast.put(plant, forecastList);
        }

        model.addAttribute("lastYearActual", lastYearActual);
        model.addAttribute("thisYearForecast", thisYearForecast);
        model.addAttribute("plants", plants);
        model.addAttribute("plantActual", plantActual);
        model.addAttribute("plantForecast", plantForecast);

        return "dashboard";
    }
}