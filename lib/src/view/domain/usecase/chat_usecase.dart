import 'package:flutter/material.dart';
import 'package:p_4/src/view/data/model/message_model.dart';
import 'package:p_4/src/view/data/model/user_model.dart';
import '../repo/helper/chat_helper_repo_header.dart';

class ChatUseCase{
  ChatHelperRepoHeader chatRepo;
  ChatUseCase( this.chatRepo);

  Future<void> sendMessage(String message,String receiverID,MessageModel? replyMessage) async => await chatRepo.sendMessage(message,receiverID,replyMessage);
  Stream<List<MessageModel>>? getMessage(BuildContext context,String receiverID,int limit)=> chatRepo.getMessage(context,receiverID,limit);
  Future<void> deleteMessage(String uid) async => await chatRepo.deleteMessagee(uid);
  Future<List<MessageModel>> getExistConversition (BuildContext context)async =>  await chatRepo.getExistConversition(context);
  Future<List<UserModel>> getExistConversitonImage(BuildContext context)async => await chatRepo.getExistConversitonImage(context);
  Future<List<UserModel>> getUsers(BuildContext context) async => await chatRepo.allUsers(context);
  String? currentUserId() => chatRepo.currentUserId();
  Future<void> isOnlineStatus(bool status) async => await chatRepo.isOnlineStatus(status);
  Future<void> sendLocationMessage(String message,String receiverID,MessageModel? replyMessage)async => await chatRepo.sendLocationMessage(message, receiverID,replyMessage);
  Future<List<MessageModel?>> getImageMessage(BuildContext context,String receiverID)async => await chatRepo.getImageMessage(context, receiverID);
  Future<List<MessageModel?>> getFileMessage(BuildContext context,String receiverID)async => await chatRepo.getFileMessage(context, receiverID);
  Future<int> lenghtOfData(String receiverID)=> chatRepo.lenghtOfData(receiverID);
  Future<void> deleteChatRoom(BuildContext context,String receiverID) => chatRepo.deleteChatRoom(context, receiverID);
}