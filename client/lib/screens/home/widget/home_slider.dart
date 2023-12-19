import 'package:carousel_slider/carousel_slider.dart';
import 'package:client/providers/slider_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeSlider extends StatefulWidget {
  const HomeSlider({Key? key}) : super(key: key);

  @override
  State<HomeSlider> createState() => _HomeSliderState();
}

class _HomeSliderState extends State<HomeSlider> {
  late Future sliderFuture;
  int _currentIndex = 0;

  @override
  void didChangeDependencies() {
    sliderFuture = Provider.of<SliderProvider>(context).getSlider();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 5),
      child: FutureBuilder(
        future: sliderFuture,
        initialData: const [],
        builder: (context, asyncData) {
          if (asyncData.connectionState == ConnectionState.waiting) {
            // Hiển thị một widget hoặc tiến trình tải ở đây nếu cần
            return CircularProgressIndicator();
          } else if (asyncData.hasError || asyncData.data.isEmpty) {
            // Xử lý khi gặp lỗi hoặc danh sách rỗng
            return _buildErrorWidget(); // Thay bằng widget thông báo hoặc ẩn widget
          }

          var sliderData = asyncData.data as List; // Không cần ép kiểu

          return Column(
            children: [
              CarouselSlider.builder(
                options: CarouselOptions(
                  height: 130,
                  autoPlay: true,
                  onPageChanged: (index, reason) {
                    setState(() {
                      _currentIndex = index % sliderData.length;
                    });
                  },
                ),
                itemCount: sliderData.length,
                itemBuilder: (BuildContext context, int index, int realIndex) {
                  return Container(
                    width: MediaQuery.of(context).size.width,
                    margin: const EdgeInsets.symmetric(horizontal: 5.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: NetworkImage(sliderData[index].image),
                      ),
                    ),
                  );
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  sliderData.length,
                  (index) {
                    return Container(
                      width: 8,
                      height: 8,
                      margin: EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 2,
                      ),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color:
                            _currentIndex == index ? Colors.blue : Colors.grey,
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildErrorWidget() {
    // Đây là nơi bạn có thể hiển thị thông báo hoặc ẩn widget CarouselSlider
    return Container(
      child: const Text('Không có dữ liệu hoặc có lỗi xảy ra'),
    );
  }
}
