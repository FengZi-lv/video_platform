import 'package:flutter/material.dart';

import '../models/models.dart';

class MockSeed {
  static List<UserProfile> users() {
    return const [
      UserProfile(
        id: 'user_current',
        nickname: '青柚放映室',
        account: 'qingyou_01',
        bio: '记录城市、影像和生活里的细小惊喜。',
        coins: 24,
        isBanned: false,
        isCurrentMember: true,
      ),
      UserProfile(
        id: 'user_02',
        nickname: '木星剪辑局',
        account: 'jupiter_cut',
        bio: '偏爱节奏感强的旅行 Vlog。',
        coins: 9,
        isBanned: false,
        isCurrentMember: false,
      ),
      UserProfile(
        id: 'user_03',
        nickname: '阿纪同学',
        account: 'aji_notes',
        bio: '沉迷记录展览和城市角落。',
        coins: 4,
        isBanned: false,
        isCurrentMember: false,
      ),
    ];
  }

  static List<VideoItem> videos() {
    return const [
      VideoItem(
        id: 'video_1',
        title: '下班后骑行 18 公里，路过灯光刚亮起的滨江',
        description: '一支带着晚风的城市骑行短片，适合在忙完一天后慢慢看完。',
        ownerId: 'user_current',
        ownerName: '青柚放映室',
        duration: '08:12',
        uploadLabel: '2 小时前',
        category: '推荐',
        coverColor: Color(0xFF2C6E6F),
        metrics: VideoMetrics(
          likes: 328,
          favorites: 190,
          coins: 65,
          comments: 26,
          views: 4821,
        ),
        isLiked: false,
        isFavorited: false,
        status: AuditStatus.approved,
      ),
      VideoItem(
        id: 'video_2',
        title: '如何把周末旅行拍得像电影感片头',
        description: '从镜头运动、剪辑节奏到配色思路，拆解一条轻量教程。',
        ownerId: 'user_02',
        ownerName: '木星剪辑局',
        duration: '11:30',
        uploadLabel: '昨天',
        category: '教程',
        coverColor: Color(0xFF8C5E34),
        metrics: VideoMetrics(
          likes: 611,
          favorites: 404,
          coins: 120,
          comments: 49,
          views: 7388,
        ),
        isLiked: true,
        isFavorited: false,
        status: AuditStatus.approved,
      ),
      VideoItem(
        id: 'video_3',
        title: '凌晨五点的菜市场，为什么总能治愈人',
        description: '从摊贩的叫卖声到烟火升起的瞬间，一次完整清晨记录。',
        ownerId: 'user_03',
        ownerName: '阿纪同学',
        duration: '05:56',
        uploadLabel: '3 天前',
        category: '纪实',
        coverColor: Color(0xFF5E7689),
        metrics: VideoMetrics(
          likes: 912,
          favorites: 520,
          coins: 208,
          comments: 88,
          views: 12120,
        ),
        isLiked: false,
        isFavorited: true,
        status: AuditStatus.approved,
      ),
      VideoItem(
        id: 'video_4',
        title: '把旧相机翻出来后，我重新认识了街头光影',
        description: '一段关于旧器材、慢节奏观察与拍摄习惯变化的分享。',
        ownerId: 'user_current',
        ownerName: '青柚放映室',
        duration: '09:42',
        uploadLabel: '1 周前',
        category: '创作',
        coverColor: Color(0xFF51624F),
        metrics: VideoMetrics(
          likes: 260,
          favorites: 143,
          coins: 53,
          comments: 19,
          views: 3190,
        ),
        isLiked: false,
        isFavorited: false,
        status: AuditStatus.approved,
      ),
      VideoItem(
        id: 'video_5',
        title: '第一次拍展览 Vlog，我踩过的 5 个坑',
        description: '关于展览拍摄许可、收音和现场节奏控制的实用经验。',
        ownerId: 'user_02',
        ownerName: '木星剪辑局',
        duration: '06:18',
        uploadLabel: '4 天前',
        category: '经验',
        coverColor: Color(0xFF6B5C8B),
        metrics: VideoMetrics(
          likes: 407,
          favorites: 230,
          coins: 73,
          comments: 34,
          views: 5470,
        ),
        isLiked: false,
        isFavorited: false,
        status: AuditStatus.approved,
      ),
      VideoItem(
        id: 'video_6',
        title: '提交审核中的样片：海边晨雾延时合集',
        description: '这是一条用于管理端审核演示的 mock 视频。',
        ownerId: 'user_current',
        ownerName: '青柚放映室',
        duration: '03:48',
        uploadLabel: '刚刚',
        category: '待审核',
        coverColor: Color(0xFF546B88),
        metrics: VideoMetrics(
          likes: 0,
          favorites: 0,
          coins: 0,
          comments: 0,
          views: 0,
        ),
        isLiked: false,
        isFavorited: false,
        status: AuditStatus.pending,
      ),
      VideoItem(
        id: 'video_7',
        title: '被驳回的旧稿：字幕样式过密测试',
        description: '用于展示管理端驳回记录的 mock 数据。',
        ownerId: 'user_03',
        ownerName: '阿纪同学',
        duration: '04:21',
        uploadLabel: '2 天前',
        category: '驳回',
        coverColor: Color(0xFF934A4A),
        metrics: VideoMetrics(
          likes: 0,
          favorites: 0,
          coins: 0,
          comments: 0,
          views: 32,
        ),
        isLiked: false,
        isFavorited: false,
        status: AuditStatus.rejected,
      ),
    ];
  }

  static Map<String, List<CommentNode>> comments() {
    return const {
      'video_1': [
        CommentNode(
          id: 'comment_1',
          videoId: 'video_1',
          authorId: 'user_02',
          authorName: '木星剪辑局',
          content: '骑行段落和配乐衔接得很顺，最后那个桥面镜头真舒服。',
          createdLabel: '18 分钟前',
          likeCount: 14,
          isLiked: false,
          replies: [
            CommentNode(
              id: 'comment_1_1',
              videoId: 'video_1',
              authorId: 'user_current',
              authorName: '青柚放映室',
              content: '谢谢，我也很喜欢那一段刚亮灯的颜色。',
              createdLabel: '12 分钟前',
              likeCount: 7,
              isLiked: true,
              replies: [],
            ),
          ],
        ),
        CommentNode(
          id: 'comment_2',
          videoId: 'video_1',
          authorId: 'user_03',
          authorName: '阿纪同学',
          content: '想知道这条路线有没有避开游客高峰，周末适合照着骑吗？',
          createdLabel: '9 分钟前',
          likeCount: 5,
          isLiked: false,
          replies: [],
        ),
      ],
      'video_2': [
        CommentNode(
          id: 'comment_3',
          videoId: 'video_2',
          authorId: 'user_current',
          authorName: '青柚放映室',
          content: '教程节奏很好，尤其是镜头运动那段很实用。',
          createdLabel: '昨天',
          likeCount: 23,
          isLiked: true,
          replies: [],
        ),
      ],
    };
  }

  static List<AuditItem> audits() {
    return const [
      AuditItem(
        id: 'audit_1',
        videoId: 'video_6',
        videoTitle: '提交审核中的样片：海边晨雾延时合集',
        uploaderName: '青柚放映室',
        submittedLabel: '10 分钟前',
        note: '检查画面内容与封面是否一致。',
        status: AuditStatus.pending,
      ),
      AuditItem(
        id: 'audit_2',
        videoId: 'video_7',
        videoTitle: '被驳回的旧稿：字幕样式过密测试',
        uploaderName: '阿纪同学',
        submittedLabel: '2 天前',
        note: '字幕遮挡画面主体，需调整后重新提交。',
        status: AuditStatus.rejected,
      ),
    ];
  }

  static List<ReportItem> reports() {
    return const [
      ReportItem(
        id: 'report_1',
        videoId: 'video_2',
        videoTitle: '如何把周末旅行拍得像电影感片头',
        reporterName: '青柚放映室',
        reason: '疑似搬运未标注来源',
        createdLabel: '今天 09:20',
        status: ReportStatus.pending,
      ),
      ReportItem(
        id: 'report_2',
        videoId: 'video_5',
        videoTitle: '第一次拍展览 Vlog，我踩过的 5 个坑',
        reporterName: '阿纪同学',
        reason: '封面文案夸张，建议复核',
        createdLabel: '昨天 22:15',
        status: ReportStatus.processed,
      ),
    ];
  }

  static List<String> historyIds() => ['video_3', 'video_2'];

  static List<String> favoriteIds() => ['video_3'];
}
