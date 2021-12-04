import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gateway/blocs/ble_device_connection/bloc/ble_device_connection_bloc.dart';
import 'package:gateway/blocs/ble_repository.dart';
import 'package:gateway/blocs/ble_scan/bloc/ble_scan_bloc.dart';
import 'package:gateway/business_logic/ble/ble_connector/bloc/ble_connector_bloc.dart';
import 'package:provider/src/provider.dart';
import 'package:reactive_ble_platform_interface/src/model/discovered_device.dart';

class TestPage extends StatefulWidget {
  const TestPage({Key? key}) : super(key: key);

  @override
  _TestPageState createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider<BleScanBloc>(
      create: (context) => BleScanBloc(context.read<BLERepository>()),
      child: BlocProvider(
        create: (context) =>
            BleDeviceConnectionBloc(repository: context.read<BLERepository>()),
        child: Scaffold(
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ScanPage(),
            ],
          ),
        ),
      ),
    );
  }
}

class ScanPage extends StatelessWidget {
  const ScanPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
            child: Text("Scan"),
            onPressed: () =>
                {context.read<BleScanBloc>().add(BLEScanRequestEvent())}),
        BlocBuilder<BleScanBloc, BleScanState>(builder: (builder, state) {
          print(state.scanState);
          if (state.scanState == ScanSate.init) {
            return const Text("INIT");
          }
          if (state.scanState == ScanSate.notFound) {
            return const Text("NOT FOUND");
          }
          if (state.scanState == ScanSate.founded) {
            return DeviceConnection(state.discoverdDevice!);
          }
          return Container(
            color: Colors.black,
            width: 20,
            height: 20,
          );
        }),
      ],
    );
  }
}

class DeviceConnection extends StatefulWidget {
  final DiscoveredDevice discoverdDevice;
  const DeviceConnection(this.discoverdDevice, {Key? key}) : super(key: key);

  @override
  _DeviceConnectionState createState() => _DeviceConnectionState();
}

class _DeviceConnectionState extends State<DeviceConnection> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(widget.discoverdDevice.toString()),
        Container(
          width: 200,
          height: 200,
          color: Colors.red,
          child: ElevatedButton(
              child: Text("Connect to" + widget.discoverdDevice.name),
              onPressed: () => {
                    context.read<BleDeviceConnectionBloc>().add(
                        BLEDeviceConnectionRequestEvent(
                            widget.discoverdDevice.id))
                  }),
        ),
        BlocBuilder<BleDeviceConnectionBloc, BleDeviceConnectionState>(
            builder: (builder, state) {
          if (state.deviceConnectionState == null) {
            return Text("Unconnected to " + widget.discoverdDevice.name);
          }
          if (state.deviceConnectionState != null) {
            return Text(state.deviceConnectionState.toString());
          }
          return Container();

          // state.deviceConnectionState!.connectionState;
        })
      ],
    );
  }
}