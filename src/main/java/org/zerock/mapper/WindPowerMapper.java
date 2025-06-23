package org.zerock.mapper;


import java.util.List;


import org.apache.ibatis.annotations.Insert;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Select;
import org.zerock.domain.WindPowerDTO;

@Mapper
public interface WindPowerMapper {

    @Insert("INSERT INTO wind_power (dgen_ymd, ippt, hogi, ippt_nam, qhor_gen01, qhor_gen02, qhor_gen03, qhor_gen04, qhor_gen05, qhor_gen06, qhor_gen07, qhor_gen08, qhor_gen09, qhor_gen10, qhor_gen11, qhor_gen12, qhor_gen13, qhor_gen14, qhor_gen15, qhor_gen16, qhor_gen17, qhor_gen18, qhor_gen19, qhor_gen20, qhor_gen21, qhor_gen22, qhor_gen23, qhor_gen24, qsum, qavg, qvod_max_s, qvod_min_s, qvod_max, qvod_min, eaidml, eaiflag, eaimsg) " +
            "VALUES (#{dgenYmd}, #{ippt}, #{hogi}, #{ipptNam}, #{qhorGen01}, #{qhorGen02}, #{qhorGen03}, #{qhorGen04}, #{qhorGen05}, #{qhorGen06}, #{qhorGen07}, #{qhorGen08}, #{qhorGen09}, #{qhorGen10}, #{qhorGen11}, #{qhorGen12}, #{qhorGen13}, #{qhorGen14}, #{qhorGen15}, #{qhorGen16}, #{qhorGen17}, #{qhorGen18}, #{qhorGen19}, #{qhorGen20}, #{qhorGen21}, #{qhorGen22}, #{qhorGen23}, #{qhorGen24}, #{qsum}, #{qavg}, #{qvodMaxS}, #{qvodMinS}, #{qvodMax}, #{qvodMin}, #{eaidml}, #{eaiflag}, #{eaimsg})")
    void insertWindPower(WindPowerDTO dto);
    
    @Select("SELECT * FROM wind_power WHERE dgen_ymd = #{date}")
    List<WindPowerDTO> selectByDate(String date);

    @Select("SELECT * FROM wind_power WHERE dgen_ymd LIKE CONCAT(#{year}, '%') ORDER BY dgen_ymd")
    List<WindPowerDTO> findByYear(String year);
}