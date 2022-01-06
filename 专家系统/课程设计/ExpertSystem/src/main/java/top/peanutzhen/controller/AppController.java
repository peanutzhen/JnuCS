package top.peanutzhen.controller;

import javafx.beans.binding.Bindings;
import javafx.fxml.FXMLLoader;
import javafx.scene.Parent;
import javafx.scene.Scene;
import javafx.scene.control.*;
import javafx.event.ActionEvent;
import javafx.fxml.FXML;
import javafx.scene.input.KeyCode;
import javafx.scene.input.KeyEvent;
import javafx.stage.Stage;
import top.peanutzhen.model.Rule;
import top.peanutzhen.model.DataModel;

import java.io.IOException;
import java.util.*;

import static top.peanutzhen.controller.Util.showDialog;

public class AppController {
    @FXML
    private TextArea progress;
    @FXML
    private TextField input;
    @FXML
    private ListView<String> conditions;
    @FXML
    public ListView<String> ruleDB;

    private DataModel model;

    public void setModel(DataModel model) {
        if (this.model != null) {
            throw new IllegalStateException("Model can only be initialized once");
        }
        this.model = model;

        conditions.setItems(model.getCondList());

        ruleDB.setItems(model.getRuleList());
        // when selected, set current rule.
        ruleDB.getSelectionModel().selectedItemProperty().addListener((obs, oldSelection, newSelection) ->
                model.setCurrentRule(newSelection));
        // when rule changed, flush select mode.
        model.currentRuleProperty().addListener((obs, oldRule, newRule) -> {
            if (newRule == null) {
                ruleDB.getSelectionModel().clearSelection();
            } else {
                ruleDB.getSelectionModel().select(newRule);
            }
        });
        // Let rule ListView has two menuItem when right click list cell.
        ruleDB.setCellFactory(lv -> {
            ListCell<String> cell = new ListCell<>();
            ContextMenu contextMenu = new ContextMenu();

            MenuItem editItem = new MenuItem();
            editItem.textProperty().bind(Bindings.format("Edit Rule"));
            editItem.setOnAction(event -> {
                try {
                    FXMLLoader loader = new FXMLLoader(getClass().getResource("/view/EditRuleView.fxml"));
                    Parent root = loader.load();
                    EditRuleController editRuleController = loader.getController();

                    model.setCurrentRuleIndex(cell.getIndex());
                    editRuleController.setModel(model);
                    editRuleController.setAddRuleMode(false);
                    editRuleController.setRuleTextArea(cell.getText());

                    Stage stage = new Stage();
                    stage.setTitle("Edit Rule");
                    stage.setScene(new Scene(root));
                    stage.show();
                } catch (IOException e) {
                    e.printStackTrace();
                    showDialog(Alert.AlertType.ERROR, "Internal error, see log file for detail.");
                }
            });

            MenuItem deleteItem = new MenuItem();
            deleteItem.textProperty().bind(Bindings.format("Delete Rule"));
            deleteItem.setOnAction(event -> ruleDB.getItems().remove(cell.getIndex()));

            contextMenu.getItems().addAll(editItem, deleteItem);

            cell.textProperty().bind(cell.itemProperty());
            cell.emptyProperty().addListener((obs, wasEmpty, isNowEmpty) -> {
                // empty cell do not show menu
                if (isNowEmpty)
                    cell.setContextMenu(null);
                else
                    cell.setContextMenu(contextMenu);
            });

            return cell;
        });
    }

    // 重置UI界面
    public void reset(ActionEvent event) {
        conditions.getItems().clear();
        input.clear();
        progress.clear();
    }

    // 添加事实到conditions中
    public void pickup(KeyEvent event) {
        if (event.getCode().equals(KeyCode.ENTER)) {
            String condition = input.getText();
            if (conditions.getItems().contains(condition)) {
                showDialog(Alert.AlertType.WARNING, "Repeated condition!");
                return;
            }
            conditions.getItems().add(condition);
            input.clear();
        }
    }

    // 添加一条规则
    public void addRule(ActionEvent event) {
        try {
            FXMLLoader loader = new FXMLLoader(getClass().getResource("/view/EditRuleView.fxml"));
            Parent root = loader.load();
            EditRuleController editRuleController = loader.getController();

            editRuleController.setModel(model);
            editRuleController.setAddRuleMode(true);

            Stage stage = new Stage();
            stage.setTitle("Add Rule");
            stage.setScene(new Scene(root));
            stage.show();
        } catch (IOException e) {
            e.printStackTrace();
            showDialog(Alert.AlertType.ERROR, "Internal error, check log for detailed.");
        }
    }

    // 加载默认数据集
    public void loadRule() {
        Alert alert = new Alert(Alert.AlertType.CONFIRMATION);
        alert.setTitle("Message");
        alert.setHeaderText("It will clear all rules currently.");
        alert.setContentText("Are you sure?");
        alert.showAndWait().ifPresent(response -> {
            if (response == ButtonType.OK) {
                try {
                    model.loadExampleRule();
                } catch (Exception e) {
                    e.printStackTrace();
                    showDialog(Alert.AlertType.ERROR, "Load default rules failed, check log for detailed.");
                }
            }
        });
    }

    // 关于作者
    public void about(ActionEvent event) {
        showDialog(Alert.AlertType.INFORMATION, "Jnu2018 LuoSheng Zhen Present.");
    }

    /**
     * 正向推理动物
     */
    public void deduce(ActionEvent event) {
        // rules 规则库
        ArrayList<Rule> rules = new ArrayList<>();
        for (String ruleExp : ruleDB.getItems())
            rules.add(Rule.valueOf(ruleExp));
        // integratedDatabase 综合数据库
        Set<String> integratedDatabase = new HashSet<>(conditions.getItems());
        StringBuilder builder = new StringBuilder();

        while (true) {
            // 判断是否有新的推理可用
            boolean change = false;
            for (Rule rule : rules) {
                // 判断数据库是否包含当前规则的所有条件
                boolean flag = true;
                for (String condition : rule.getCondition()) {
                    if (!integratedDatabase.contains(condition)) {
                        flag = false;
                        break;
                    }
                }
                // 满足当前规则所有条件
                if (flag) {
                    // 将当前规则结果加入数据库
                    if (!integratedDatabase.contains(rule.getConclusion())) {
                        integratedDatabase.add(rule.getConclusion());
                        change = true;
                        builder.append(String.format(
                                "Using rule: %s\nGet: %s\nCurrent integated database: %s\n\n",
                                rule,
                                rule.getConclusion(),
                                integratedDatabase
                        ));
                    }

                    // 如果是目标集元素，推理结束， 输出结果至inferProgress
                    if (model.getConclusions().contains(rule.getConclusion())) {
                        builder.append("Final result: " + rule.getConclusion());
                        progress.setText(builder.toString());
                        return;
                    }
                }
            }
            // 没有新推理可用
            if (!change)
                break;
        }
        builder.append("Final result: Cannot deduce this animal.");
        progress.setText(builder.toString());
    }
}
