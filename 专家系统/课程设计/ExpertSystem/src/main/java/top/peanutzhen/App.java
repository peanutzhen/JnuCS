package top.peanutzhen;

import javafx.application.Application;
import javafx.fxml.FXMLLoader;
import javafx.scene.Parent;
import javafx.scene.Scene;
import javafx.stage.Stage;
import top.peanutzhen.controller.AppController;
import top.peanutzhen.model.DataModel;

import java.io.IOException;

public class App extends Application {
    public static void main(String[] args) {
        launch(args);
    }

    @Override
    public void start(Stage primaryStage) throws IOException {
        primaryStage.setTitle("ExpertSystem Demo");

        FXMLLoader appLoader = new FXMLLoader(getClass().getResource("/view/AppView.fxml"));
        Parent root = appLoader.load();
        AppController appController = appLoader.getController();

        DataModel model = new DataModel();
        appController.setModel(model);

        primaryStage.setScene(new Scene(root));
        primaryStage.setResizable(false);
        primaryStage.centerOnScreen();
        primaryStage.show();
    }
}
