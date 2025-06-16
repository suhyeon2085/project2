package org.zerock.controller;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
public class PowerSimpleController {

    @GetMapping("/wind")
    public String windData(Model model) {
        List<Map<String, Object>> powerData = new ArrayList<>();
        powerData.add(Map.of("date", "2025-06-01", "actual", 120, "predicted", 115));
        powerData.add(Map.of("date", "2025-06-02", "actual", 130, "predicted", 128));
        powerData.add(Map.of("date", "2025-06-03", "actual", 140, "predicted", 138));

        model.addAttribute("powerData", powerData);
        return "simpleWind";  // 뷰 이름
    }
}