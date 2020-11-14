/**
* Name: EnglishAuction
* Based on the internal empty template. 
* Author: Spycsh
* Tags: 
*/


model EnglishAuction

/* Insert your model definition here */
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
//	int lowerInterval;
//	int price;
//	int minPrice;
	int price;
	int round;
	string merch;
	list<Participant> participantList;
	Participant roundWinner <- nil; // the winner of a round
	Participant winner <- nil;
	bool allJoin <- false;
	int pcounter <- 0;
//	bool belowMinPrice <- false;
	
	bool informWinnerFlag;
	
	init
	{
		price <- rnd(40, 50);  // initial price
//		lowerInterval <- int ((price-minPrice)/10);
		merch <- 'a ticket for performance';
		round <- 0;
		inAuction <- false;
		
	}
	
	//inform all participants the auction is going to start
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
	
	//receive the join confirmation from participants
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
//			write 'all join:'+pcounter;
			write 'all participants join the auction';
		}
	}
	
	//broadcast the initial price
	reflex broadcastInitialPrice when: inAuction and empty(proposes) and allJoin and winner=nil
	{
		write 'Auctioneer, round ' + round +', time '+ time + ': broadcast the initial price.';
		do start_conversation (to: participantList, protocol: 'fipa-contract-net', performative: 'cfp', contents: [price,round]);
	
	}
	
	//receive feedback from participants
	reflex receiveFeedback when : inAuction and !(empty(proposes)) and winner = nil and allJoin
	{

		pcounter <- 0;
		loop p over:proposes
		{
			list content <- list(p.contents);
			string decision <- content[0]; 
			write 'Auctioneer, round ' + round + ', time ' + time + ':receive from ' + agent(p.sender).name + ' ' + decision;
			pcounter <- pcounter + 1;
			
//				if(decision = 'give up'){
//					inAuction <- false;
//					winner <- p.sender;
//					write 'Auctioneer announces that winner is: ' + agent(p.sender).name;
//				}else if(pcounter=length(participantList)){	// receive all the proposes from participants
//					round <- round + 1;
//					// propose the next price
//					price <- price - lowerInterval;
//					
//					// if below minimum price, cancel the auction
//					if(price<minPrice){
//						write 'below minimum price, cancel the auction';
//						belowMinPrice<-true;
//					}else{
//						write 'Auctioneer, round ' + round + ', time ' + time + 'propose a new price: ' + price;
//						// inform the participants of the new price
//						do start_conversation (to: participantList, protocol: 'fipa-contract-net', performative: 'cfp', contents: [price,round]);
//					}
//					
//				}
			if(decision = 'give up'){//remove the participants who wants to give up
				remove agent(p.sender) from: participantList;
			}else{ 
				// decision = 'raise'
				int proposedPrice <- content[1];
				if(proposedPrice > price){
					price <- proposedPrice;
					roundWinner<- p.sender;
					write agent(p.sender).name + " raise the price at " + price;
				}
			}
		}
		
		
		if(length(participantList)=1){//when there is only one participant left
			winner <- roundWinner;
			write "only " + winner + " remains, others all give up!";
			write "winner is: " + winner;
		}else if(pcounter=length(participantList)){//if all participants has proposed, start next round
			round <- round + 1;
			do start_conversation (to: participantList, protocol: 'fipa-contract-net', performative: 'cfp', contents: [price,round]);	
		}
		
		
	}

	//inform the winner
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
//	int acceptPrice <- rnd(200,400);
//	int acceptPrice <- rnd(0, 100);

	// In English auction the max accepted price should be marketPrice add maxLosePremium
	// because the max lose money that one risk should be the max accepted price minus marketPrice
	int marketPrice <- 100;
	int maxLosePremium <- rnd(150, 300);  // the premium one can afford most

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
	
	//receive auction start message
	reflex receiveStartAuctionMsg when : (!empty(informs)) and targetPoint = nil and !joinAuction
	{
		targetPoint<- arena;
		write self.name + ' time: ' + time + ' receive broadcast, go to join the broadcast';
		color <- #green;
	}
	
	//confirms to participant the auction when arrives the arena
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
	
	reflex receivePrice when: (!empty(cfps)) and location distance_to arena < 16 and joinAuction
	{
		message msg <- cfps[0];
		list content <- list(msg.contents);
		price <- int(content[0]);
		round <- int(content[1]);
		write self.name + ' round ' + round +', time '+ time + ': receive price ' + price;
		if (price <= marketPrice + maxLosePremium)
		{
			price <- price + int(((marketPrice + maxLosePremium)-price) / 2);
			write self.name + ' round ' + round +', time '+ time + ': bid a price ' + price;
			do propose with: (message:msg, contents: ['raise', price]);
		}
		else
		{
			write self.name + ' round ' + round +', time '+ time + ': give up to raise price ';
			do propose with: (message:msg, contents: ['give up', price]);
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
