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
	int number_of_stores<-4;
	int number_of_infoCenter<-1;
	init{
		create FestivalGuests number:number_of_guests;
		create FestivalStores number:number_of_stores;
		create FestivalInformationCenter number:number_of_infoCenter;
	}
	
}

species FestivalGuests skills:[moving]
{
	point targetPoint<-nil;
	bool thirst<-false;
	bool hunger<-false;
	reflex beIdle when:targetPoint = nil
	{
		do wander;
	}
	
	reflex moveToTarget when:targetPoint != nil
	{
		do goto target:targetPoint;
	}
	
	reflex enterStore when:location distance_to(targetPoint) < 2
	{
	}
	
	aspect base{
		draw circle(2) color: #yellow;
		
	}
	
}

species FestivalStores 
{
	
	aspect base{
		draw square(2) color: #green;
		
	}
	
}

species FestivalInformationCenter 
{
	aspect base{
		draw square(3) color: #blue;
		
	}
	
}

experiment main type:gui
{
	output
	{
		display map type:opengl
		{
			species FestivalGuests aspect:base;
			species FestivalStores aspect:base;
			species FestivalInformationCenter aspect:base;
			
		}
	}
	
}