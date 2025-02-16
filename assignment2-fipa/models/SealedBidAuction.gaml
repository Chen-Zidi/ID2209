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
	int price <- 0;
	string merch;
	list<Participant> participantList;
	Participant winner <- nil;
	bool allJoin <- false;
	int pcounter <- 0;
	
	bool informWinnerFlag;
	
	init
	{

		merch <- 'a ticket for performance';
		inAuction <- false;
		
	}
	
		
	//send start auction message
	reflex startAuction when: time = 1 
	{
		
		ask Participant 
		{
			myself.participantList << self;
		}
		
		write 'Auctioneer, time '+ time + ': broadcast the auction is about to start.';
		do start_conversation (to: participantList, protocol: 'no-protocol', performative: 'inform', contents: ['start auction', merch]);
		inAuction <- true;
	
	}
	
	//ensure that all participants prepares to join the auction
	reflex receiveJoinFeedBack when: inAuction and !(empty(informs)) and !allJoin
	{
		pcounter <- 0;
		loop i over:informs
		{
			//write 'join: ' + i.contents;
			pcounter <- pcounter + 1;
			//write pcounter;
		}
		
	
		if(pcounter = length(participantList) )
		{
			allJoin <- true;
			//write 'all join:'+pcounter;
			write 'all participants join the auction';
		}
	}
	
	//ask for bids
	reflex askForBids when: inAuction and empty(proposes) and allJoin and winner=nil 
	{
		write "ask for bids";
		do start_conversation (to: participantList, protocol: 'fipa-contract-net', performative: 'cfp', contents: ["please send bids"]);
	
	}
	
	//receive the feedback from the participant
	reflex receiveBids when : inAuction and !(empty(proposes)) and winner = nil and allJoin
	{
		pcounter <- 0;
		loop p over:proposes
		{
			
				list content <- list(p.contents);
				int receivedPrice <- content[0]; 
				write 'Auctioneer' + ', time ' + time + ': receive from ' + agent(p.sender).name + ' ' + receivedPrice;
				pcounter <- pcounter + 1;
					if(receivedPrice > price){
						winner <- p.sender;
						price <- receivedPrice;
					}
				
					if(pcounter = length(participantList)){
						inAuction <- false;
						write 'Auctioneer announces that winner is: ' + winner.name;
					
					}
			}
			
			
		}
	

	//inform all participants the winner
	reflex informWinner when : winner!=nil and informWinnerFlag = false
	{
		do start_conversation (to: participantList, protocol: 'no-protocol', performative: 'inform', contents: [winner]);
		
	}



	
	aspect base
	{
		draw sphere(3) color: #yellow;
	}
}

species Participant skills:[fipa,moving]
{
	rgb color <- #grey;
	point arena <- {50,50};
	point targetPoint <- nil;
	int price <- rnd(300,500);
	bool joinAuction <- false;
	
	bool winnerFlag <- false;
	
	//receive winner
	reflex receiveWinnerInfo when: (!empty(informs)) and location distance_to arena < 16 and joinAuction and !winnerFlag
	{
		Participant winner <- list(informs[0].contents)[0];
		if(winner=self){//check if myself is the winner
			self.color <- #black;
			write self.name + ' knows that he is the winner';
			winnerFlag <- true;	
		}
	}
	
	//receive the auction start message
	reflex receiveStartAuctionMsg when : (!empty(informs)) and targetPoint = nil and !joinAuction
	{
		targetPoint<- arena;//move to the arena
		write self.name + ' time: ' + time + ' receive broadcast, go to join the broadcast';
		color <- #green;
	}
	
	//when the participant arrives the area, it reports that it is ready to join the auction
	reflex confirmAuctionStart when : location distance_to arena < 16 and (!empty(informs)) and !joinAuction
	{
		joinAuction <- true;
		do inform with:(message: informs[0], contents: ['join auction from ' + agent(informs[0].sender).name, self]);
	}
	
	//move to the arena
	reflex moveToArena when: targetPoint != nil and targetPoint = {50,50} and location distance_to arena > 15
	{
		
		do goto target:targetPoint;
	}
	
	//send bid to the auctioneer
	reflex sendBid when:  location distance_to arena < 16 and joinAuction and !(empty(cfps))
	{
		
		
		write self.name +', time '+ time + ': send bid ' + price;
		do propose with: (message:cfps[0], contents: [price]);
		
		
		
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