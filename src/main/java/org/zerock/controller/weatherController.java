package org.zerock.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
public class weatherController {
	@RequestMapping("/weather")
	public String main() {
		return "weather";
	}
}
