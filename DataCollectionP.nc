#include <Timer.h>
#include "DataMsg.h"

module DataCollectionP
{
  uses{
    interface Timer<TMilli> as TimerApp;
    interface Leds;
    interface Boot;
    interface PacketAcknowledgements as Acks;
    interface Packet;
    interface AMPacket;
    interface AMSend;
    interface SplitControl as AMControl;
    interface Receive;
    interface Random;
    interface Queue<DataMsg> as MyQueue;
    interface TreeConnection;
  }
}
implementation
{
  uint16_t my_parent;
  message_t pkt;

  event void Boot.booted(){
    call AMControl.start();
  }

  event void AMControl.startDone(error_t err){
    if (err != SUCCESS){
      call AMControl.start();
    }
  }

  event void AMControl.stopDone(error_t err){}

  task void forwardMessage(){

    DataMsg* msg = (DataMsg*) (call Packet.getPayload(&pkt,NULL));
    msg -> prova = 5;
    dbg("routing","contenuto:%u\n",msg -> prova);
  }

  task void submitMessage(){
    DataMsg* msg = (DataMsg*) (call Packet.getPayload(&pkt,NULL));
    msg -> prova = my_parent;
    //call Acks.requestAck(msg);
    //call MyQueue(msg);
  }

  event void TimerApp.fired(){
  }

  event void AMSend.sendDone(message_t* msg, error_t error)
  {
    if (&pkt == msg && error == SUCCESS){      
    }
  }

  event message_t* Receive.receive(message_t* msg, void* payload, uint8_t len)
  {
    if (len == sizeof(DataMsg)){
    }
    return msg;
  }

  event void TreeConnection.parentUpdate(uint16_t parent){
    my_parent = parent;
    post submitMessage();
  }
}
