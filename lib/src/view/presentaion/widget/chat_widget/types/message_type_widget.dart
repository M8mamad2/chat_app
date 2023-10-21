import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:p_4/src/config/theme/theme.dart';
import 'package:p_4/src/core/common/sizes.dart';
import 'package:p_4/src/view/data/model/message_model.dart';
import 'package:p_4/src/view/presentaion/blocs/setting_blocs/font_size_bloc.dart';
import 'dart:ui' as ui;

import '../../../../../config/theme/notification/notification_service.dart';
import '../message_bubble_widget.dart';

class MessageTypeWidget extends StatefulWidget {
  final Alignment aligment;
  final MessageModel data;
  final bool isMine;
  const MessageTypeWidget({super.key,required this.aligment,required this.data,required this.isMine,});

  @override
  State<MessageTypeWidget> createState() => _MessageTypeWidgetState();
}

class _MessageTypeWidgetState extends State<MessageTypeWidget> {
  LocalNotificationService notification = LocalNotificationService();
  @override
  void initState() {
    super.initState();
    context.read<FontSizeBloc>().add(GetFontSizeEvent());
    context.read<BorderRadiusBloc>().add(GetBorderRadiusEvent());
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // log('in Did Change');
    // if(widget.isMine) notif('Message', widget.data.messsage, widget.data.senderID);
  // notif(String title,String body,String channel)async => await notification.addNotification(title, body, channel);
  }


  

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      alignment: widget.aligment,
      widthFactor: 0.6,
      child: Align(
        alignment: widget.aligment,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 20.0),
          child: BlocBuilder<BorderRadiusBloc,BorderRadiusState>(
            builder:(context, state) {
              log(state.toString());
              if(state is LoadedBorderRadiusState){
               return ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(state.borderRadius)),
                  child: BubbleBackground(
                      colors: [
                        if (widget.isMine) ...[theme(context).primaryColor , theme(context).primaryColor.withOpacity(0.5),] 
                        else ...[theme(context).primaryColor , theme(context).primaryColor.withOpacity(0.5),],
                      ],
                      child: BlocBuilder<FontSizeBloc,FontSizeState>(
                        builder: (context, state) {
                          if(state is LoadedFontSizeState){
                            return DefaultTextStyle.merge(
                              style: theme(context).textTheme.labelLarge!.copyWith(fontSize: state.fontSize,color: theme(context).backgroundColor,),
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Stack(
                                  alignment:widget.isMine ? Alignment.bottomRight : Alignment.bottomLeft,
                                  children: [
                                  Padding(
                                    padding:widget.isMine ? const EdgeInsets.only(right: 10) : const EdgeInsets.only(left: 10),
                                    child: Text(widget.data.messsage),
                                  ),
                                  Icon(Icons.check,size: 10,color: theme(context).backgroundColor,)  
                                  ]),
                              ),
                            );
                          }
                          return Container(width: 100,height: 100,color: Colors.amber,);
                        },
                      ),
                    ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }
}



