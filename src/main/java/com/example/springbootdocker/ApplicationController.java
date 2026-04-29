package com.example.springbootdocker;

import java.util.Map;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class ApplicationController {

    @GetMapping("/health")
    public String health() {
        return "OK";
    }

    @GetMapping("/search")
    public Map<String, String> search() {
        return Map.of("query", "example", "result", "sample data");
    }
}
