package top.peanutzhen.model;

import java.util.Arrays;
import java.util.HashSet;
import java.util.Set;

// Rule 仅当所有条件成立，才能推断出结论
public class Rule {
    private Set<String> condition;
    private String conclusion;
    private String ruleExp;

    public Rule() {
        this.condition = new HashSet<>();
    }

    // valueOf 从ruleExp解析得到rule
    public static Rule valueOf(String ruleExp) {
        String[] pair = ruleExp.split("->");
        if (pair.length != 2)
            return null;
        Rule rule = new Rule();
        rule.condition.addAll(Arrays.asList(pair[0].split("&")));
        rule.conclusion = pair[1];
        rule.ruleExp = ruleExp;
        return rule;
    }

    public Set<String> getCondition() {
        return this.condition;
    }

    public String getConclusion() {
        return this.conclusion;
    }

    @Override
    public String toString() {
        // 返回规定的语法形式
        return this.ruleExp;
    }

    @Override
    public int hashCode() {
        return this.ruleExp.hashCode();
    }

    @Override
    public boolean equals(Object obj) {
        if (obj == null)
            return false;
        if (this == obj)
            return true;
        if (obj.getClass() != getClass())
            return false;
        Rule other = (Rule) obj;
        return other.ruleExp.equals(this.ruleExp);
    }
}

