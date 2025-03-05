########################
# CitiBike Desert Analysis
# Takes all 


library(tidyverse)
library(lubridate)
library(sf)
library(tigris)
library(gganimate)


citibike <- read_csv("../data/citibike_110724.csv")
stations <- read_sf("../data/stations_geo_110724.geojson")
roads_data = primary_secondary_roads("NY") 
landmarks_data = landmarks("NY", type = 'area') 
tracts_data = tracts("NY", county =c("New York", "Kings", "Queens", "Bronx")) 
nj_tracts_data = tracts("NJ", county =c("Bergen", "Hudson")) 


nyc_boroughs <- counties(state = "NY", cb = TRUE, class = "sf") %>%
  filter(NAME %in% c("New York", "Kings", "Queens", "Bronx")) %>% 
  st_transform(., crs = st_crs(stations) )# NYC borough counties 

nj <- counties(state = "NJ", cb = TRUE, class = "sf")  

nyc_water = area_water(state = "NY", county = c("New York", "Kings", "Queens", "Bronx") ) 

nj_water = area_water(state = "NJ", county = c("Bergen", "Hudson") ) 



hourly_citibike <- citibike %>%
  filter(is_renting == 1, is_returning == 1) %>%
  mutate(last_updated = ymd_hms(last_updated),
         in_service = ifelse(num_docks_available == 0 | num_bikes_available == 0, 0, 1),
         docks_available = ifelse(num_docks_available == 0, 0, 1),
         bikes_available = ifelse(num_bikes_available + num_ebikes_available == 0, 0, 1),
         weekend = ifelse(wday(last_updated, week_start = 1) < 6, "weekday", "weekend")) %>%
  group_by(service_hour = hour(last_updated), station_id, weekend) %>%
  summarize(
    avg_available = mean(num_docks_available / capacity, na.rm = TRUE),
    returning = mean(docks_available, na.rm = TRUE),
    renting = mean(bikes_available, na.rm = TRUE),
    in_service = mean(in_service, na.rm = TRUE),
    .groups = 'drop'
  ) %>%
  mutate(
    rent_return_status = case_when(
      returning <= 0.8 ~ "Full Station (More than 20%)",
      returning <= 0.9 ~ "Full Station (More than 10%)",
      renting <= 0.8 ~ "Empty Station (More than 20%)",
      renting <= 0.9 ~ "Empty Station (More than 10%)",
      .default = "Okay"
    ),
    service_status = case_when(
      in_service > 0.9 ~ "Good (Above 90%)",
      in_service <= 0.9 & in_service >= 0.8 ~ "Okay (Between 90% and 80%)",
      in_service < 0.8 ~ "Bad (Less than 80%)"
    )
  ) %>%  
  left_join(stations, by = "station_id") %>% 
  st_as_sf(sf_column_name = 'geometry') %>%
  st_intersection(nyc_boroughs)  %>%  
  filter(!st_is_empty(geometry))

limits = st_bbox(hourly_citibike$geometry)

hourly_citibike %>%  
  filter(service_hour == 2) %>%
  ggplot() + 
  geom_sf(data = nyc_boroughs, color = "black", fill = "#F4F2F2") +
  geom_sf(data = tracts_data, color = "lightgrey", fill = "#F4F2F2") + 
  geom_sf(data = nj, color = "black", fill = "#F4F2F2") +
  geom_sf(data = nj_tracts_data, color = "lightgrey", fill = "#F4F2F2") +
  geom_sf(data = nyc_water, fill = '#ADD8E6') + 
  geom_sf(data = nj_water, fill = 'lightblue') + 
  geom_sf(data = roads_data, color = 'lightgrey') + 
  geom_sf(data = landmarks_data, color = 'lightgrey', fill = "#dfede0") + 
  geom_sf(data = hourly_citibike, color = "darkgrey", size = .4) +
  coord_sf(xlim = c(as.numeric(limits$xmin),as.numeric(limits$xmax)), 
           ylim = c(as.numeric(limits$ymin),as.numeric(limits$ymax))) +
  theme_void() +
  guides(color = "none")


#### 8AM 


- hourly_citibike %>%  
  filter(service_hour == i) %>%
  ggplot() + 
  geom_sf(data = nyc_boroughs, color = "black", fill = "#F4F2F2") +
  geom_sf(data = tracts_data, color = "lightgrey", fill = "#F4F2F2") + 
  geom_sf(data = nj, color = "black", fill = "#F4F2F2") +
  geom_sf(data = nj_tracts_data, color = "lightgrey", fill = "#F4F2F2") +
  geom_sf(data = nyc_water, fill = '#ADD8E6') + 
  geom_sf(data = nj_water, fill = 'lightblue') + 
  geom_sf(data = roads_data, color = 'lightgrey') + 
  geom_sf(data = landmarks_data, color = 'lightgrey', fill = "#dfede0") + 
  geom_sf(aes(color = service_status), size = .4) +
  scale_color_manual(name = "Average Service Status", values = c("Good (Above 90%)" = "green", "Okay (Between 90% and 80%)" = "orange", "Bad (Less than 80%)" = "red")) +
  coord_sf(xlim = c(as.numeric(limits$xmin),as.numeric(limits$xmax)), 
           ylim = c(as.numeric(limits$ymin),as.numeric(limits$ymax))) +
  theme_void() +
  guides(color = "none")

ggsave(filename = paste0("src/img/map", i, ".png"), plot = hour_plot, width = 4, height = 8)