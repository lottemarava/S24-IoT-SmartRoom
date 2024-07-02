#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "driver/uart.h"
#include "esp_log.h"
#include "ld2410.h"
#include "motion_function.h"
static const char *TAG = "LD2410";

//uart_param_config(uart_num, &uart_config);
//uart_set_pin(uart_num, uart_tx_pin, uart_rx_pin, UART_PIN_NO_CHANGE, UART_PIN_NO_CHANGE);
//uart_driver_install(uart_num, 2048, 0, 0, NULL, 0);

 /*

   uart_config_t uart_config = {
        .baud_rate = 256000,
        .data_bits = UART_DATA_8_BITS,
        .parity = UART_PARITY_DISABLE,
        .stop_bits = UART_STOP_BITS_1,
        .flow_ctrl = UART_HW_FLOWCTRL_DISABLE,
        .source_clk = UART_SCLK_APB,
    };

  if (radar.begin(uart_config)) {
          ESP_LOGI(TAG, "Radar initialized successfully.");
          ESP_LOGI(TAG, "LD2410 firmware version: %d.%d.%X",
                  radar.firmware_major_version,
                  radar.firmware_minor_version,
                  radar.firmware_bugfix_version);
      } else {
          ESP_LOGE(TAG, "Radar initialization failed.");
          return;
      }
      */
////////////////////////////////loop
void detectMotion() {
    // Replace with code specific to reading from your new sensor
    int sensorValue =radar.read();  // Example: Replace with actual sensor read function
    if (radar.isConnected() && radar.presenceDetected()&& radar.stationaryTargetDetected()) {
                    //ESP_LOGI(TAG, "Last Seen: %d", lastSeen[i % size]);//ESP_LOGI(TAG, "Stationary target: %d cm",//      radar.stationaryTargetDistance());debug
        if (radar.stationaryTargetDistance() - 60 >= lastSeen[i % size]) {

           if (configured || manually_configured) {
              my_now = millis() / 1000;
              // Adjust for rollover if necessary
              if (my_now < last_motion) {
                  my_now += 4294967;
              }
              
              // Check delay conditions
              if (my_now - last_motion >= delay_time) {
                  motion_detected = false;
                  offset = 5 - (my_now - last_motion - delay_time);
              }
              
              // Act based on timing conditions
              if ((my_now - last_motion >= delay_time + 5 && my_now - first_motion >= delay_time + 10) || last_motion == 4294967) {
                  actAccordingTime();
                  offset = 0;
              } else {
                  actAccordingTime(true);
              }
                    } else {
                        lastSeen[i % size] = radar.stationaryTargetDistance();
                        i++;
                        sum = 0;
                        for (int x = 0; x < 10; x++) {
                            sum += lastSeen[x];
                        }
                        if (sum <= 80) {
                          j++;
                            ESP_LOGI(TAG, "UP!!");
                            Serial.print("UP! debug purpose");
                            if (!motion_detected) {
                                first_motion = millis() / 1000 - offset;
                            }
                            motion_detected = true;
                            my_now = millis() / 1000;
          
                              // Adjust for rollover if necessary
                              if (my_now < first_motion) {
                                  my_now += 4294967;
                              }
                              
                              last_motion = millis() / 1000;
                              
                              // Act according to configured times
                              if (configured || manually_configured) {
                                  actAccordingTime(true);
                              } else if (!connecting) {
                                  actAccordingTime();
                                  connectWithPref();
                              }
                        }
            }
        }
       } else if (!connecting) {
              actAccordingTime();
              connectWithPref();
          }
    }










