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
	
	
	init{
		create Guests number:number_of_guests;
		create Store number:2 {
			sellFood <- true;	
			
		}
		create Store number:2 {
			sellDrink <- true;	
			
		}
//		create Store number:number_of_stores;
		create InformationCenter number:number_of_infoCenter{
			location <- {50, 50};
		}
		
	}
	
}

species Guests skills:[moving]
{
	//target store
	point targetPoint<-nil;
	
	//location of information center
	point infoCenter<-{50,50};
	
	int thirst<-0;
	int hunger<-0;
	rgb color<-#grey;
	
	init{
			thirst <- rnd(100);
			
			if(thirst>50){//if thirsty
				
				hunger<-rnd(50);//set not hungry(<=50)
				color<-#blue;
				
			}else{//if not thirsty
				hunger <- 80;//set hungry
				color<-#green;
			}
	}
	
	reflex beIdle when:targetPoint = nil
	{
		do wander;
	}
	
	//if thirsty or hungry and do not know the stores
	reflex gotoInfoCenter when:(hunger > 50 or thirst >50) and targetPoint = nil{
		do goto target:infoCenter;
		ask InformationCenter at_distance 2{
			if(myself.thirst > 50){
				//randomly choose a bar
				int i <- rnd(length(self.bars) - 1);
				myself.targetPoint <- self.bars[i];
				
				
			}else if(myself.hunger > 50){
				//randomly choose a restaurant
				int i <- rnd(length(self.restaurants) - 1);
				myself.targetPoint <- self.restaurants[i];
				
			}
			
		}
	}
	
	reflex moveToTarget when:targetPoint != nil
	{
		do goto target:targetPoint;
	}
	
	//when enter the store
	reflex enterStore when:targetPoint != nil and location distance_to(targetPoint) < 2
	{
		
		if (self.thirst > 50) {//if thirsty
				self.thirst <- rnd(50);//not thirsty any more
			} else {//if hungry
				self.hunger <- rnd(50);//not hungry any more
			}
		targetPoint <- nil;
		color <- #grey;
	}
	
	//change status of the guest who is not thirsty and hungry
	reflex changeStatus when: thirst <= 50 and hunger <= 50 {
			thirst <- thirst + 2;
			hunger <- hunger + 2;
			if(thirst > 50){//if thirsty
				hunger <- rnd(50);//reset hunger(randomly)
				color<-#blue;
			}else if(hunger>50){//if hungry
				thirst<- rnd(50);//reset thirsty(randomly)
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

experiment main type:gui
{
	output
	{
		display map type:opengl
		{
			species Guests aspect:base;
			species Store aspect:base;
			species InformationCenter aspect:base;
			
		}
	}
	
}