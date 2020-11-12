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
	list<Participant> winnerList;
	Participant winner <- nil;
	bool allJoin <- false;
	int pcounter <- 0;
	bool belowMinPrice <- false;
	
	bool informWinnerFlag;
	
	init
	{
		price <- rnd(500,550);
		minPrice <- rnd(100,150);
		lowerInterval <- int ((price-minPrice)/10);
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
		
		write 'Auctioneer, time '+ time + ': broadcast the auction is about to start.';
		do start_conversation (to: participantList, protocol: 'no-protocol', performative: 'inform', contents: ['start auction', merch]);
		inAuction <- true;
	
	}
	
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
			write 'all join:'+pcounter;
			write 'all participants join the auction';
		}
	}
	
	reflex broadcastInitialPrice when: inAuction and empty(proposes) and allJoin and winner=nil and !belowMinPrice
	{
		write 'Auctioneer, round ' + round +', time '+ time + ': broadcast the initial price.';
		do start_conversation (to: participantList, protocol: 'fipa-contract-net', performative: 'cfp', contents: [price,round]);
	
	}
	
	reflex receiveFeedback when : inAuction and !(empty(proposes)) and winner = nil and allJoin and !belowMinPrice
	{
		pcounter <- 0;
		loop p over:proposes
		{
			if winner=nil and !belowMinPrice{
				list content <- list(p.contents);
				string decision <- content[0]; 
				write 'Auctioneer, round ' + round + ', time ' + time + ':receive from ' + agent(p.sender).name + ' ' + decision;
				pcounter <- pcounter + 1;
				
				if(decision = 'accept'){
					inAuction <- false;
					winner <- p.sender;
					write 'Auctioneer announces that winner is: ' + agent(p.sender).name;
				}else if(pcounter=length(participantList)){	// receive all the proposes from participants
					round <- round + 1;
					// propose the next price
					price <- price - lowerInterval;
					
					// if below minimum price, cancel the auction
					if(price<minPrice){
						write 'below minimum price, cancel the auction';
						belowMinPrice<-true;
					}else{
						write 'Auctioneer, round ' + round + ', time ' + time + 'propose a new price: ' + price;
						// inform the participants of the new price
						do start_conversation (to: participantList, protocol: 'fipa-contract-net', performative: 'cfp', contents: [price,round]);
					}
					
				}
			}
			
		}
	}

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
	int round <- 0;
	int price <- 0;
	int acceptPrice <- rnd(200,400);
//	int acceptPrice <- rnd(0, 100);
	bool joinAuction <- false;
	
	bool winnerFlag <- false;
	
	reflex receiveWinnerInfo when: (!empty(informs)) and location distance_to arena < 16 and joinAuction and !winnerFlag
	{
		Participant winner <- list(informs[0].contents)[0];
		if(winner=self){
			self.color <- #black;
			write self.name + ' knows that he is the winner';
			winnerFlag <- true;	
		}
	}
	
	
	reflex receiveStartAuctionMsg when : (!empty(informs)) and targetPoint = nil and !joinAuction
	{
		targetPoint<- arena;
		write self.name + ' time: ' + time + ' receive broadcast, go to join the broadcast';
		color <- #green;
	}
	
	reflex confirmAuctionStart when : location distance_to arena < 16 and (!empty(informs)) and !joinAuction
	{
		joinAuction <- true;
		do inform with:(message: informs[0], contents: ['join auction from ' + agent(informs[0].sender).name, self]);
	}
	
	reflex moveToArena when: targetPoint != nil and targetPoint = {50,50} and location distance_to arena > 15
	{
		
		do goto target:targetPoint;
	}
	
	reflex receivePrice when: (!empty(cfps)) and location distance_to arena < 16 and joinAuction
	{
		message msg <- cfps[0];
		list content <- list(msg.contents);
		price <- int(content[0]);
		round <- int(content[1]);
		write self.name + ' round ' + round +', time '+ time + ': receive price ' + price;
		if (price <= acceptPrice)
		{
			write self.name + ' round ' + round +', time '+ time + ': accept price ' + price;
			do propose with: (message:msg, contents: ['accept', price]);
		}
		else
		{
			write self.name + ' round ' + round +', time '+ time + ': reject price ' + price;
			do propose with: (message:msg, contents: ['reject', price]);
		}
		
		
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