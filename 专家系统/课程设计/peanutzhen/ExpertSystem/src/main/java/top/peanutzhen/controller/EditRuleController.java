package top.peanutzhen.controller;

import javafx.event.ActionEvent;
import javafx.fxml.FXML;
import javafx.scene.Node;
import javafx.scene.control.Alert;
import javafx.scene.control.CheckBox;
import javafx.scene.control.TextArea;
import javafx.stage.Stage;
import top.peanutzhen.model.Rule;
import top.peanutzhen.model.DataModel;

import static top.peanutzhen.controller.Util.showDialog;

public class EditRuleController {
    @FXML
    private TextArea ruleTextArea;
    @FXML
    private CheckBox flag;

    private DataModel model;
    private boolean addRuleMode;

    public void setModel(DataModel model) {
        this.model = model;
    }

    public void setAddRuleMode(boolean on) {
        this.addRuleMode = on;
    }

    public void setRuleTextArea(String text) {
        ruleTextArea.setText(text);
    }

    public void resetEditRule(ActionEvent event) {
        ruleTextArea.clear();
    }

    public void saveRule(ActionEvent event) {
        String ruleExp = ruleTextArea.getText();
        if (ruleExp.length() == 0) {
            showDialog(Alert.AlertType.ERROR, "Empty rule!");
            return;
        }

        Rule rule = Rule.valueOf(ruleExp);
        if (rule == null) {
            showDialog(Alert.AlertType.ERROR, "Illegal rule format!");
            return;
        }

        if (addRuleMode)
            model.getRuleList().add(ruleExp);
        else
            model.getRuleList().set(model.getCurrentRuleIndex(), ruleExp);

        if (flag.isSelected())
            model.getConclusions().add(rule.getConclusion());

        ((Stage)((Node)event.getSource()).getScene().getWindow()).close();
    }
}
