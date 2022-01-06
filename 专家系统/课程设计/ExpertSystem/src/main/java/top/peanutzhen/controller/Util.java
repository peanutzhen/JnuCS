package top.peanutzhen.controller;

import javafx.application.Platform;
import javafx.scene.control.Alert;

class Util {
    // 显示一个通知
    public static void showDialog(Alert.AlertType alertType, String message) {
        Platform.runLater(() -> {
            Alert alert = new Alert(alertType);
            alert.setTitle("Message");
            alert.setContentText(message);
            alert.showAndWait();
        });
    }
}
