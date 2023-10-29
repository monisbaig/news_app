import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:getwidget/getwidget.dart';
import 'package:news_app/auth/controller/stories_controller.dart';
import 'package:news_app/screens/details_screen.dart';

import '../common/global_variables.dart';
import '../widgets/custom_textfield.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    var storyData = ref.watch(storiesProvider);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20.r),
            bottomRight: Radius.circular(20.r),
          ),
        ),
        backgroundColor: Colors.grey.shade300,
        surfaceTintColor: Colors.grey.shade300,
        title: Text(
          'New York Top Articles',
          style: TextStyle(
            fontSize: 19.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: storyData.when(
        data: (data) {
          var searchData = data.results?.where(
            (element) => element.title!
                .toLowerCase()
                .replaceAll(' ', '')
                .contains(searchController.text),
          );
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.sp, vertical: 10.sp),
            child: CustomScrollView(
              clipBehavior: Clip.none,
              slivers: [
                SliverToBoxAdapter(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: 205.w,
                        child: CustomTextField(
                          hint: 'Search',
                          controller: searchController,
                          prefixIcon: Icon(
                            Icons.search,
                            color: Colors.grey.shade500,
                          ),
                          onChanged: (value) {
                            setState(() {
                              searchController.text = value;
                            });
                          },
                        ),
                      ),
                      IconButton(
                        onPressed: () async {
                          await showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                elevation: 0,
                                backgroundColor: Colors.white,
                                title: const Text('Filter By Sections:'),
                                content: Row(
                                  children: [
                                    ElevatedButton(
                                      onPressed: () {
                                        setState(() {
                                          section = 'home';
                                          ref.refresh(storiesProvider);
                                          Navigator.of(context).pop();
                                        });
                                      },
                                      child: const Text('Home'),
                                    ),
                                    SizedBox(width: 4.w),
                                    ElevatedButton(
                                      onPressed: () {
                                        setState(() {
                                          section = 'food';
                                          ref.refresh(storiesProvider);
                                          Navigator.of(context).pop();
                                        });
                                      },
                                      child: const Text('Food'),
                                    ),
                                    SizedBox(width: 4.w),
                                    ElevatedButton(
                                      onPressed: () {
                                        setState(() {
                                          section = 'world';
                                          ref.refresh(storiesProvider);
                                          Navigator.of(context).pop();
                                        });
                                      },
                                      child: const Text('World'),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                        icon: const Icon(
                          Icons.filter_alt_rounded,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            selectView = true;
                          });
                        },
                        icon: Icon(
                          Icons.format_list_bulleted_rounded,
                          color: selectView ? Colors.blue : Colors.black,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            selectView = false;
                          });
                        },
                        icon: Icon(
                          Icons.grid_view_rounded,
                          color: selectView ? Colors.black : Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(height: 4.h),
                ),
                selectView
                    ? SliverList.separated(
                        separatorBuilder: (context, index) =>
                            SizedBox(height: 10.h),
                        itemCount: searchData?.length ?? 0,
                        itemBuilder: (context, index) {
                          var storyData = searchData?.elementAt(index);

                          return GFListTile(
                            color: Colors.grey.shade300,
                            padding: EdgeInsets.zero,
                            margin: EdgeInsets.zero,
                            shadow: const BoxShadow(
                              blurRadius: 0,
                              spreadRadius: 0,
                            ),
                            radius: 20.r,
                            avatar: Container(
                              width: 100.w,
                              height:
                                  MediaQuery.of(context).size.height * 0.10.sp,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(20.r),
                                  bottomLeft: Radius.circular(20.r),
                                ),
                                color: Colors.grey.shade300,
                                image: DecorationImage(
                                  image: NetworkImage(
                                    '${storyData?.multimedia?.elementAt(0).url}',
                                  ),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            title: Text(
                              '${storyData?.title}',
                              textAlign: TextAlign.justify,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subTitle: Text(
                              '${storyData?.byline}',
                              textAlign: TextAlign.justify,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.grey.shade700,
                              ),
                            ),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => DetailsScreen(
                                    title: storyData!.title!,
                                    description: storyData.abstract!,
                                    image:
                                        storyData.multimedia!.elementAt(0).url!,
                                    author: storyData.byline!,
                                    url: storyData.url!,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      )
                    : SliverGrid(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10.sp,
                          mainAxisSpacing: 10.sp,
                          childAspectRatio: 0.6.sp,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          childCount: searchData?.length ?? 0,
                          (context, index) {
                            var storyData = searchData?.elementAt(index);

                            return InkWell(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => DetailsScreen(
                                      title: storyData!.title!,
                                      description: storyData.abstract!,
                                      image: storyData.multimedia!
                                          .elementAt(0)
                                          .url!,
                                      author: storyData.byline!,
                                      url: storyData.url!,
                                    ),
                                  ),
                                );
                              },
                              child: GFCard(
                                boxFit: BoxFit.cover,
                                padding: EdgeInsets.zero,
                                margin: EdgeInsets.zero,
                                color: Colors.grey.shade300,
                                elevation: 0,
                                image: Image.network(
                                  '${storyData?.multimedia?.elementAt(0).url}',
                                  fit: BoxFit.cover,
                                  width: MediaQuery.of(context).size.width,
                                  height: MediaQuery.of(context).size.height *
                                      0.14.sp,
                                ),
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(20.r),
                                  topRight: Radius.circular(20.r),
                                ),
                                showImage: true,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.r),
                                ),
                                title: GFListTile(
                                  padding: EdgeInsets.only(top: 4.h),
                                  margin: EdgeInsets.zero,
                                  title: Text(
                                    '${storyData?.title}',
                                    textAlign: TextAlign.justify,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subTitle: Text(
                                    '${storyData?.byline}',
                                    textAlign: TextAlign.justify,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
              ],
            ),
          );
        },
        error: (error, stackTrace) {
          return Center(
            child: Text(
              error.toString(),
              style: TextStyle(
                color: Colors.red,
                fontSize: 15.sp,
              ),
            ),
          );
        },
        loading: () {
          return Center(
            child: GFLoader(
              type: GFLoaderType.ios,
              size: 40.sp,
            ),
          );
        },
      ),
    );
  }
}
