/**
* Name: DutchAuction
* Based on the internal empty template. 
* Author: Zidi Chen, Sihan Chen
* Tags: 
*/


model DutchAuctionMultiple

global
{
	
	int number_of_participant<-10;
	
	
	init
	{
		create Participant number:number_of_participant;
		create Arena number:1
		{
			
			location<-{50,50};
		}
		create Arena number:1
		{
			
			location<-{20,20};
		}
		create Arena number:1
		{
			
			location<-{80,80};
		}
		create Auctioneer number:1
		{
			id<-0;
			location<-{20,20};
			merch<-'CD';
		}
		
		create Auctioneer number:1
		{
			id<-1;
			location<-{80,80};
			merch<-'cloth';
		}
		
		create Auctioneer number:1
		{
			id<-2;
			location<-{50,50};
			merch<-'painting';
		}
	}
	
}

species Auctioneer skills:[fipa]
{
	bool inAuction;
	int id;
	int lowerInterval;
	int price;
	int minPrice;
	int round;
	string merch ;
	list<Participant> participantList;
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
		
		round <- 0;
		inAuction <- false;
		
	}
	
		
	//send start auction message
	reflex startAuction when: time = 1 
	{
		
		ask Participant 
		{
			if(self.interestedMerch = myself.merch)
			{
				myself.participantList << self;
			}
			
		}
		
		write 'Auctioneer'+id+', sells '+merch+', time '+ time + ': broadcast the auction is about to start.';
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
			write 'all interested participants join the auction for '+ merch;
		}
	}
	
	//broadcast the initial price
	reflex broadcastInitialPrice when: inAuction and empty(proposes) and allJoin and winner=nil and !belowMinPrice
	{
		write 'Auctioneer'+id+', sells '+merch+', round ' + round +', time '+ time + ': broadcast the initial price.';
		do start_conversation (to: participantList, protocol: 'fipa-contract-net', performative: 'cfp', contents: [price,round]);
	
	}
	
	//receive the feedback from the participant
	reflex receiveFeedback when : inAuction and !(empty(proposes)) and winner = nil and allJoin and !belowMinPrice
	{
		pcounter <- 0;
		loop p over:proposes
		{
			if winner=nil and !belowMinPrice{
				list content <- list(p.contents);
				string decision <- content[0]; 
				write 'Auctioneer'+id+', sells '+merch+', round ' + round + ', time ' + time + ': receive from ' + agent(p.sender).name + ' ' + decision;
				pcounter <- pcounter + 1;
				
				if(decision = 'accept'){//the participant accept the price
					inAuction <- false;
					winner <- p.sender;//set the winner
					write 'Auctioneer'+id+', sells '+merch+' announces that winner is: ' + agent(p.sender).name;
				}else if(pcounter=length(participantList)){	// receive all the proposes from participants
					round <- round + 1;
					// propose the next price
					price <- price - lowerInterval;
					
					// if below minimum price, cancel the auction
					if(price<minPrice){
						write 'Auction for '+merch+': below minimum price, cancel the auction';
						belowMinPrice<-true;
					}else{
						write 'Auctioneer'+id+', sells '+merch+', round ' + round + ', time ' + time + ': propose a new price: ' + price;
						// inform the participants of the new price
						do start_conversation (to: participantList, protocol: 'fipa-contract-net', performative: 'cfp', contents: [price,round]);
					}
					
				}
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
	string interestedMerch;
	rgb color <- #grey;
	point arena ;
	point targetPoint <- nil;
	int round <- 0;
	int price <- 0;
	int acceptPrice <- rnd(200,400);
//	int acceptPrice <- rnd(0, 100);
	bool joinAuction <- false;
	
	bool winnerFlag <- false;
	
	init{
		//decide interested merch
		int temp<-rnd(0,300);
		if(temp <= 100){
			interestedMerch <- "cloth";
			arena <- {80,80};
		}else if(temp > 100 and temp <= 200){
			interestedMerch <- "CD";
			arena <- {20,20};
		}else{
			interestedMerch <- "painting";
			arena <- {50,50};
		}
	}
	
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
		write self.name + ' acceptable price: ' + acceptPrice;
	}
	
	//move to the arena
	reflex moveToArena when: targetPoint != nil and targetPoint = arena and location distance_to arena > 15
	{
		
		do goto target:targetPoint;
	}
	
	//receive the price from the auctioneer
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