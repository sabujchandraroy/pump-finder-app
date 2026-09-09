import 'package:flutter/material.dart';
import '../../domain/entities/petrol_pump.dart';

class PumpCard extends StatelessWidget {
  final PetrolPump pump;
  final VoidCallback? onTap;
  final VoidCallback? onFavorite;
  const PumpCard({super.key, required this.pump, this.onTap, this.onFavorite});
  @override
  Widget build(BuildContext context) => Card(margin: EdgeInsets.zero, child: InkWell(borderRadius: BorderRadius.circular(16), onTap:onTap, child: Padding(padding:const EdgeInsets.all(16), child:Row(children:[CircleAvatar(radius:24,child:Icon(pump.isOpen?Icons.local_gas_station:Icons.gas_meter)),const SizedBox(width:12),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(pump.name,maxLines:1,overflow:TextOverflow.ellipsis,style:const TextStyle(fontWeight:FontWeight.w700)),const SizedBox(height:4),Text(pump.address,maxLines:2,overflow:TextOverflow.ellipsis),const SizedBox(height:6),Row(children:[const Icon(Icons.star,size:16),const SizedBox(width:4),Text('${pump.rating.toStringAsFixed(1)} (${pump.reviewCount})'),if(pump.distanceKm>0)...[const SizedBox(width:12),Text('${pump.distanceKm.toStringAsFixed(1)} km')]])])),IconButton(onPressed:onFavorite,tooltip:pump.isFavorite?'Remove from favorites':'Add to favorites',icon:Icon(pump.isFavorite?Icons.favorite:Icons.favorite_border))]))));
}
