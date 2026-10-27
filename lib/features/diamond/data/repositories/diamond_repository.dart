import '../datasources/diamond_remote_datasource.dart';
import '../models/diamond_model.dart';

abstract class DiamondRepository {
  Future<bool> addToCart({
    required String stock,
    int qty = 1,
  });

  Future<DiamondResponseModel> getDiamondList({

    int page = 0,
    int perPage = 50,
    String stock = "",
    List<String>? shapes,
    List<String>? colors,
    List<String>? fancyColors,
    List<String>? clarities,
    List<String>? cuts,
    List<String>? polishes,
    List<String>? symmetries,
    List<String>? labs,
    List<String>? fluorescences,
    List<String>? makes,
    List<String>? culets,
    List<String>? available,
    String? caratFrom,
    String? caratTo,
    String? priceFrom,
    String? priceTo,
    String? ratioFrom,
    String? ratioTo,
    String? depthFrom,
    String? depthTo,
    String? tableFrom,
    String? tableTo,
    String? crAngleFrom,
    String? crAngleTo,
    String? crHeightFrom,
    String? crHeightTo,
    String? pavAngleFrom,
    String? pavAngleTo,
    String? pavHeightFrom,
    String? pavHeightTo,
    String? girdleFrom,
    String? girdleTo,
    String? starLengthFrom,
    String? starLengthTo,
  });
}

class DiamondRepositoryImpl implements DiamondRepository {
  final DiamondRemoteDataSource remoteDataSource;

  DiamondRepositoryImpl({required this.remoteDataSource});

  @override
  Future<DiamondResponseModel> getDiamondList({

    int page = 0,
    int perPage = 50,
    String stock = "",
    List<String>? shapes,
    List<String>? colors,
    List<String>? fancyColors,
    List<String>? clarities,
    List<String>? cuts,
    List<String>? polishes,
    List<String>? symmetries,
    List<String>? labs,
    List<String>? fluorescences,
    List<String>? makes,
    List<String>? culets,
    List<String>? available,
    String? caratFrom,
    String? caratTo,
    String? priceFrom,
    String? priceTo,
    String? ratioFrom,
    String? ratioTo,
    String? depthFrom,
    String? depthTo,
    String? tableFrom,
    String? tableTo,
    String? crAngleFrom,
    String? crAngleTo,
    String? crHeightFrom,
    String? crHeightTo,
    String? pavAngleFrom,
    String? pavAngleTo,
    String? pavHeightFrom,
    String? pavHeightTo,
    String? girdleFrom,
    String? girdleTo,
    String? starLengthFrom,
    String? starLengthTo,
  }) async {

    return await remoteDataSource.getDiamondList(
      page: page,
      perPage: perPage,
      stock: stock,
      shapes: shapes,
      colors: colors,
      fancyColors: fancyColors,
      clarities: clarities,
      cuts: cuts,
      polishes: polishes,
      symmetries: symmetries,
      labs: labs,
      fluorescences: fluorescences,
      makes: makes,
      culets: culets,
      available: available,
      caratFrom: caratFrom,
      caratTo: caratTo,
      priceFrom: priceFrom,
      priceTo: priceTo,
      ratioFrom: ratioFrom,
      ratioTo: ratioTo,
      depthFrom: depthFrom,
      depthTo: depthTo,
      tableFrom: tableFrom,
      tableTo: tableTo,
      crAngleFrom: crAngleFrom,
      crAngleTo: crAngleTo,
      crHeightFrom: crHeightFrom,
      crHeightTo: crHeightTo,
      pavAngleFrom: pavAngleFrom,
      pavAngleTo: pavAngleTo,
      pavHeightFrom: pavHeightFrom,
      pavHeightTo: pavHeightTo,
      girdleFrom: girdleFrom,
      girdleTo: girdleTo,
      starLengthFrom: starLengthFrom,
      starLengthTo: starLengthTo,
    );
  }

  @override
  Future<bool> addToCart({
    required String stock,
    int qty = 1,
  }) async {
    return await remoteDataSource.addToCart(
      stock: stock,
      qty: qty,
    );
  }
}

