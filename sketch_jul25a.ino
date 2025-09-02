#include <ESP8266WiFi.h>
#include <ESP8266WebServer.h>

const char* ssid = "MicroclimateESP";
const char* password = "12345678";

const int ledPin = 0; // GPIO0 — LED to simulate fan
ESP8266WebServer server(80);

void setup() {
  pinMode(ledPin, OUTPUT);
  digitalWrite(ledPin, LOW); // Start with LED off

  Serial.begin(115200);
  WiFi.softAP(ssid, password);
  Serial.println("WiFi AP Started. Connect to:");
  Serial.println(WiFi.softAPIP());

  server.on("/control", HTTP_POST, []() {
    if (server.hasArg("fan")) {
      String state = server.arg("fan");
      if (state == "on") {
        digitalWrite(ledPin, HIGH); // Turn LED ON
        Serial.println("Fan ON (LED ON)");
      } else if (state == "off") {
        digitalWrite(ledPin, LOW); // Turn LED OFF
        Serial.println("Fan OFF (LED OFF)");
      } else {
        Serial.println("Unknown fan command.");
      }
    }
    server.send(200, "text/plain", "OK");
  });

  server.begin();
  Serial.println("HTTP server started");
}

void loop() {
  server.handleClient();
}
