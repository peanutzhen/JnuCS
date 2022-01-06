package top.peanutzhen.model;

import javafx.beans.property.SimpleStringProperty;
import javafx.collections.FXCollections;
import javafx.collections.ObservableList;

import java.io.*;
import java.nio.charset.StandardCharsets;
import java.util.HashSet;
import java.util.Set;

public class DataModel {
    private final ObservableList<String> ruleList = FXCollections.observableArrayList();
    private final ObservableList<String> condList = FXCollections.observableArrayList();

    private final SimpleStringProperty currentRule = new SimpleStringProperty();
    private int currentRuleIndex;

    // 推导结果集合
    private final Set<String> conclusions = new HashSet<>();

    public ObservableList<String> getRuleList() {
        return ruleList;
    }

    public ObservableList<String> getCondList() {
        return condList;
    }

    public Set<String> getConclusions() {
        return conclusions;
    }

    public SimpleStringProperty currentRuleProperty() {
        return currentRule;
    }

    public final void setCurrentRule(String rule) {
        currentRuleProperty().set(rule);
    }

    public int getCurrentRuleIndex() {
        return currentRuleIndex;
    }

    public void setCurrentRuleIndex(int currentRuleIndex) {
        this.currentRuleIndex = currentRuleIndex;
    }

    // 导入教材的规则集
    public void loadExampleRule() throws Exception {
        ruleList.clear();
        conclusions.clear();

        try (InputStream stream = getClass().getResourceAsStream("/data/rules.txt");) {
            BufferedReader r = new BufferedReader(new InputStreamReader(stream));
            for (String rule; (rule = r.readLine()) != null; )
                ruleList.add(rule);

            conclusions.add("虎");
            conclusions.add("豹");
            conclusions.add("斑马");
            conclusions.add("长颈鹿");
            conclusions.add("企鹅");
            conclusions.add("鸵鸟");
            conclusions.add("信天翁");
        } catch (Exception e) {
            throw new Exception("Load rule failed", e);
        }
    }
}
