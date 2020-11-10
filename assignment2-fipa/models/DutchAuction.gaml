/**
* Name: DutchAuction
* Based on the internal empty template. 
* Author: Zidi Chen, Sihan Chen
* Tags: 
*/


model DutchAuction

global
{
	int number_of_auctioneer<-1;
	int number_of_participant<-10;
	
	
	init
	{
		create Participant number:number_of_participant;
		create Arena number:1
		{
			location<-{50,50};
		}
		create Auctioneer number:number_of_auctioneer
		{
			location<-{50,50};
		}
	}
	
}

species Auctioneer skills:[fipa]
{
	bool inAuction;
	int lowerInterval;
	int price;
	int minPrice;
	int round;
	string merch;
	list<Participant> participantList;
	
	init
	{
		price <- rnd(500,550);
		minPrice <- rnd(100,150);
		lowerInterval <- (price-minPrice)/10;
		merch <- 'a ticket for performance';
		round <- 0;
		inAuction <- false;
	}
	
		
	reflex startAuction when: time = 1 
	{
		ask Participant 
		{
			myself.participantList << self;
		}
		
		write 'Auctioneer, '+ time + ': broadcast the auction is about to start.';
		do start_conversation (to: participantList, protocol: 'no-protocol', performative: 'inform', contents: ['start auction', merch]);
		inAuction <- true;
	
	}

	reflex broadcastInitialPrice when: inAuction = true and empty(agrees) and empty(refuses)
	{
		write 'Auctioneer, round ' + round +', '+ time + ': broadcast the initial price.';
		do start_conversation (to: participantList, protocol: 'fipa-contract-net', performative: 'cfp', contents: [price,round]);
	
	inAuction <- false;
	}
	
//	reflex receiveRefusedMsg when : !(empty(refuses))
//	{
//		
//		loop r over:refuses
//		{
//			write agent(r.sender).name +', '+ time+': ' + 'refuse with content'+'r.contents';
//		}
//	}



	
	aspect base
	{
		draw sphere(3) color: #yellow;
	}
}

species Participant skills:[fipa,moving]
{
	rgb color <- #grey;
	point arena <- {50,50};
	point targetPoint;
	int round<-0;
	
//	bool output<-true;
	
	reflex receiveStartAuctionMsg when : (!empty(informs)) and targetPoint = nil 
	{
		targetPoint<- arena;
		write 'Participant, ' +time+': receive broadcast, go to join the broadcast';
		do end_conversation message: informs[0] contents: ['join auction from ' + agent(informs[0].sender).name, self];
		
	}
	
	reflex moveToArena when: targetPoint != nil and targetPoint = {50,50} and location distance_to arena > 15
	{
		
		do goto target:targetPoint;
	}
	
//	reflex receivePrice when: (!empty(cfps)) and output and location distance_to arena < 16
	reflex receivePrice when: (!empty(cfps)) and location distance_to arena < 16
	{
		
		write 'Participant, round ' + round +', '+time+': receive price ' + cfps[0].contents;
//		output<-false;
	}
	
	

	
	aspect base
	{
		draw sphere(2) color: color;
	}
}


species Arena
{
	aspect base
	{
		draw circle(15) color: #purple;
	}
}

experiment main type:gui
{
	output
	{
		display map type:opengl
		{
			
			
			species Arena aspect:base;
			species Auctioneer aspect:base;
			species Participant aspect:base;
			
		}
	}
	
}