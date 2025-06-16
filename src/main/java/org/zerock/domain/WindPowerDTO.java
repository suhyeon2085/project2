package org.zerock.domain;

import lombok.Data;

@Data
public class WindPowerDTO {
    private String dgenYmd;    // 날짜
    private String ippt;       // 발전소 코드
    private String hogi;       // 시간 구분
    private String ipptNam;    // 발전소 이름

    private double qhorGen01;
    private double qhorGen02;
    private double qhorGen03;
    private double qhorGen04;
    private double qhorGen05;
    private double qhorGen06;
    private double qhorGen07;
    private double qhorGen08;
    private double qhorGen09;
    private double qhorGen10;
    private double qhorGen11;
    private double qhorGen12;
    private double qhorGen13;
    private double qhorGen14;
    private double qhorGen15;
    private double qhorGen16;
    private double qhorGen17;
    private double qhorGen18;
    private double qhorGen19;
    private double qhorGen20;
    private double qhorGen21;
    private double qhorGen22;
    private double qhorGen23;
    private double qhorGen24;

    private double qsum;
    private double qavg;
    private double qvodMaxS;
    private double qvodMinS;
    private double qvodMax;
    private double qvodMin;

    private String eaidml;
    private String eaiflag;
    private String eaimsg;
}