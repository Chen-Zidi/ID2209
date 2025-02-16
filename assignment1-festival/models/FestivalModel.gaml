/**
* Name: FestivalModel
* Based on the internal empty template. 
* Author: Zidi Chen, Sihan Chen
* Tags: 
*/


model FestivalModel

global
{
	int number_of_guests<-10;
//	int number_of_stores<-3;
	int number_of_infoCenter<-1;
	int threshold <- 500;
	
	// the times of all agents that visit the stores
	// when it comes to 100
	// calculate the distances for the agents without a small brain to travel
	int store_visit_times<-0;
	int whole_distances<-0;
	
	
	init{
		create Guests number:number_of_guests;
		create Store number:1 {
			sellFood <- true;
			location <- {20,10};	
		}
		
		create Store number:1 {
			sellFood <- true;
			location <- {20, 90};
		}
		create Store number:1 {
			sellDrink <- true;	
			location <- {80, 10};
			
		}
		
		create Store number:1 {
			sellDrink <- true;	
			location <- {80, 90};
			
		}
//		create Store number:number_of_stores;
		create InformationCenter number:number_of_infoCenter{
			location <- {85, 50};
		}
		
		create Arena number:1{
			location<-{50, 50};
		}
		
	}
	
}

species Guests skills:[moving]
{
	//target store
	point targetPoint<-nil;
	
	//location of information center
	point infoCenter<-{85, 50};
	
	point arena<-{50, 50};
	
	int thirst<-0;
	int hunger<-0;
	rgb color<-#grey;
	
	
	init{
			thirst <- rnd(threshold);
			hunger <- rnd(threshold);
	}
	
	reflex beIdle when:targetPoint = nil
	{
		do wander;
	}
	
	reflex goToArena when:(hunger < threshold and thirst <threshold) and targetPoint = nil and location distance_to(arena) > 15
	{
		do goto target:arena;
	}
	
	
	
	//if thirsty or hungry and do not know the stores
	reflex gotoInfoCenter when:(hunger > threshold or thirst >threshold) and targetPoint = nil{
		do goto target:infoCenter;
		
		whole_distances <- whole_distances + 1;
		
		
		
		ask InformationCenter at_distance 2{
			if(myself.thirst > threshold){
				//randomly choose a bar
				int i <- rnd(length(self.bars) - 1);
				myself.targetPoint <- self.bars[i];
				
				
			}else if(myself.hunger > threshold){
				//randomly choose a restaurant
				int i <- rnd(length(self.restaurants) - 1);
				myself.targetPoint <- self.restaurants[i];
				
				
			}
			
		}
	}
	
	reflex moveToTarget when:targetPoint != nil
	{
		do goto target:targetPoint;
		
		whole_distances <- whole_distances + 1;
	}
	
	//when enter the store
	reflex enterStore when:targetPoint != nil and location distance_to(targetPoint) < 8
	{
		store_visit_times <- store_visit_times + 1;
		
		// when the times to visit a store comes to 100
		// calculate the whole distances for the agents without a small brain to travel
		if(store_visit_times=100){
			write("The distance of visiting stores 100 times is: "+whole_distances);
			store_visit_times <- 0;
			whole_distances <- 0;
		}
		
		if (self.thirst > threshold) {//if thirsty
				self.thirst <- rnd(threshold);//not thirsty any more
			} else {//if hungry
				self.hunger <- rnd(threshold);//not hungry any more
			}
		targetPoint <- nil;
		color <- #grey;
	}
	
	//change status of the guest who is not thirsty and hungry
	reflex changeStatus when: thirst <= threshold and hunger <= threshold {
			thirst <- thirst + 1;
			hunger <- hunger + 1;
			if(thirst > threshold){//if thirsty
				hunger <- rnd(threshold);//reset hunger(randomly)
				color<-#blue;
			}else if(hunger>threshold){//if hungry
				thirst<- rnd(threshold);//reset thirsty(randomly)
				color <-#green;
			}
	}
	
	aspect base{
		draw sphere(2) color: color;
		
	}
	
}

species Store 
{
	bool sellDrink<-nil;
	bool sellFood<-nil;
	
	//randomly decide this store to sell drink or food
//	init{
//		if(sellDrink = nil and sellFood = nil){
//			sellDrink <- flip(0.5);
//			if(sellDrink = false){
//				sellFood<-true;
//			}
//		
//		}
//	}
	
	aspect base{
		draw cube(8) color: (sellDrink)? #blue: #green;
		
	}
	
}



species InformationCenter 
{
	
	list<Store> restaurants <- nil;
	list<Store> bars <- nil;
	
	init {
		ask Store {
			if(self.sellDrink = true){
				myself.bars << self;
			}else if(self.sellFood = true){
				myself.restaurants<<self;
				
			}	
		}
		write restaurants;
		write bars; 

	}
	
	aspect base{
		draw pyramid(15) color: #red;
		
	}
	
}

species Arena
{
	aspect base{
		draw circle(15) color: #purple;
	}
}

experiment main type:gui
{
	output
	{
		display map type:opengl
		{
			species Guests aspect:base;
			species Store aspect:base;
			species InformationCenter aspect:base;
			species Arena aspect:base;
			
		}
	}
	
}