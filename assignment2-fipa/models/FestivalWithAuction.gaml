/**
* Name: FestivalWithAuction
* Based on the internal empty template. 
* Author: Zidi, Sihan
* Tags: 
*/


model FestivalWithAuction

global
{
	int number_of_guests<-10;
//	int number_of_stores<-3;
	int number_of_infoCenter<-1;
	int threshold <- 500;
	
	
	
	init{
		create Guests number:number_of_guests;

		
		create SecurityGuard number:1{
			location<-{5,5};
		}
		
		
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



species SecurityGuard skills:[moving]
{
	point badAgentLocation;
	bool hasReport<-false;
	
	reflex gotoBadAgent when:hasReport=true
	{
		do goto target:badAgentLocation;
		
		
		
	}
	
	reflex gotoDefaultPosition when:hasReport=false
	{
		
		do goto target:{5,5};		
	}

	reflex removeBadAgent when:hasReport = true and location distance_to(badAgentLocation) < 0.2 
	{

		hasReport<-false;
		ask Guests at_distance 0.2
		//ask Guests at_location(Guests,badAgentLocation)
		{
			
			//write("I find the bad guest");
			if(self.bad=true)
			{
				//write(myself.hasReport);
				do die;
				
			}
			
		}

	}
	
	aspect base{
		draw sphere(3) color: #black;
		
	}
}

species Guests skills:[moving]
{
	//target store
	point targetPoint<-nil;
	
	//location of information center
	point infoCenter<-{85, 50};
	
	point arena<-{50, 50};
	
	bool bad<-flip(0.2);
	bool findBadAgent<-false;
	point badAgentLocation;
	
	
	int thirst<-0;
	int hunger<-0;
	
	bool visitNew <- flip(0.3);
	
	
	rgb color<-#grey;
	
	// if one Guest has visited a restaurant or bar, he will keep the information
	list<Store> restaurants <- nil;
	list<Store> bars <- nil;
	
	
	
	init
	{
			thirst <- rnd(threshold);
			hunger <- rnd(threshold);
			if(bad = true){
				color<-#black;
			}
	}
	
//	reflex beBad when:bad=true
//	{
//		do wander;
//		
//	}
	
	reflex gotoInfoCenterAskForSecurityGuard when:findBadAgent = true and bad = false and targetPoint = nil
	{
		color<-#red;
		do goto target:infoCenter;
		ask InformationCenter at_distance 2{
			write("I am going to the security guard");
			myself.targetPoint <- self.securityGuardLocation;
		}
	}
	
	reflex reachSecurityGuard when:targetPoint != nil and location distance_to(targetPoint) < 4 and findBadAgent = true and bad = false
	{
		ask SecurityGuard at_distance 4
		{
			self.badAgentLocation<-myself.badAgentLocation;
			self.hasReport<-true;
			
		}	
		do goto target:badAgentLocation;
		findBadAgent<-false;	
	}
	
	
	reflex goToArena when:(hunger < threshold and thirst <threshold) and targetPoint = nil and location distance_to(arena) > 15 and findBadAgent = false
	{
		do goto target:arena;
	}
	
	// if the guest has already visited a center, he need not go to info center again
	// the guest finds the store location from the memory 
	// guest have 30% probability that he/she want to visit a new place (visitNew)
	reflex revisitStore when: targetPoint = nil and visitNew = false and (hunger > threshold or thirst >threshold){
		//write("I want to go to old place");
		if(thirst>threshold and length(self.bars)>0){
			
				targetPoint <- self.bars[0];
			
		}
		else if(hunger>threshold and length(self.restaurants)>0){
			
				targetPoint <- self.restaurants[0];
			
			
		}
		
	}
	
	reflex findBadAgent when:findBadAgent = false and bad = false
	{
		
		ask Guests at_distance 2{
			
			if(self.bad = true){
			
				myself.badAgentLocation<-self.location;
				myself.findBadAgent <- true;
				
			}
		}
	}
	
	//if thirsty or hungry and do not know the stores
	reflex gotoInfoCenter when:(hunger > threshold or thirst >threshold) and targetPoint = nil and findBadAgent = false and bad = false
	{
		
		
		//write("I want to go to new place!");
		do goto target:infoCenter;
		
		
		// ask a guest near him whether the guest know the 
		ask Guests at_distance 2{
			if(self.bad = false){
			
			if(myself.thirst > threshold and length(self.bars)>0){
				myself.targetPoint <- self.bars[0];//get the bar location from other agent
				myself.bars << self.bars[0];
			}
			else if(myself.hunger > threshold and length(self.restaurants)>0){
				myself.targetPoint <- self.restaurants[0];//get restaurant location from other agent
				myself.restaurants << self.restaurants[0];
			}
			
			}
			
		}
		
		ask InformationCenter at_distance 2{
			if(myself.thirst > threshold){
				//randomly choose a bar
				int i <- rnd(length(self.bars) - 1);
				myself.targetPoint <- self.bars[i];
				
				// keep the information of the bar he will directly visit in future
				myself.bars << self.bars[i];
				
				
				
			}else if(myself.hunger > threshold){
				//randomly choose a restaurant
				int i <- rnd(length(self.restaurants) - 1);
				myself.targetPoint <- self.restaurants[i];
				
				// keep the information of the restaurants he will directly visit in future 
				myself.restaurants << self.restaurants[i];
				
			}
			
		}
	}
	
	reflex beIdle when:targetPoint = nil and bad = false
	{
		do wander;
	}
	
	reflex moveToTarget when:targetPoint != nil
	{
		do goto target:targetPoint;
	}
	
	//when enter the store
	reflex enterStore when:targetPoint != nil and location distance_to(targetPoint) < 8 and findBadAgent = false and bad = false
	{
		
		if (self.thirst > threshold) {//if thirsty
		
				self.thirst <- rnd(threshold);//not thirsty any more
			} else {//if hungry
				self.hunger <- rnd(threshold);//not hungry any more
			}
		targetPoint <- nil;
		color <- #grey;
	}
	
	//change status of the guest who is not thirsty and hungry
	reflex changeStatus when: thirst <= threshold and hunger <= threshold and findBadAgent = false and bad=false
	{
			thirst <- thirst + 1;
			hunger <- hunger + 1;
			if(thirst > threshold){//if thirsty
				//decide to go to a new place or not
				//30% to go to a new place
				visitNew <- flip(0.3);
				//write(visitNew);
				
				hunger <- rnd(threshold);//reset hunger(randomly)
				color<-#blue;
			}else if(hunger>threshold){//if hungry
				//decide to go to a new place or not
				//30% to go to a new place
				visitNew <- flip(0.3);
				//write(visitNew);
				
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
	point securityGuardLocation <- {5,5};
	
	init {
		ask Store {
			if(self.sellDrink = true){
				myself.bars << self;
			}else if(self.sellFood = true){
				myself.restaurants<<self;
				
			}	
		}
		
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
			species SecurityGuard aspect:base;
			
		}
	}
	
}
