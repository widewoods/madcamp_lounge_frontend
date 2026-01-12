class RecommendCategory {
  const RecommendCategory({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.keyword,
  });

  final String id;
  final String title;
  final String subtitle;
  final String imageUrl;
  final String keyword;
}

const recommendCategories = <RecommendCategory>[
  RecommendCategory(
    id: 'boardgame',
    title: '보드게임',
    subtitle: '3개 장소',
    imageUrl:
    'https://images.unsplash.com/photo-1610890716171-6b1bb98ffd09?auto=format&fit=crop&w=1200&q=80',
    keyword: '보드게임카페',
  ),
  RecommendCategory(
    id: 'bowling',
    title: '볼링',
    subtitle: '3개 장소',
    imageUrl:
    'https://images.unsplash.com/photo-1521537634581-0dced2fee2ef?auto=format&fit=crop&w=1200&q=80',
    keyword: '볼링장',
  ),
  RecommendCategory(
    id: 'pc',
    title: 'PC방',
    subtitle: '3개 장소',
    imageUrl:
    'https://images.unsplash.com/photo-1527443154391-507e9dc6c5cc?auto=format&fit=crop&w=1200&q=80',
    keyword: 'PC방',
  ),
  RecommendCategory(
    id: 'billiard',
    title: '당구',
    subtitle: '3개 장소',
    imageUrl:
    'https://images.unsplash.com/photo-1529692236671-f1f6cf9683ba?auto=format&fit=crop&w=1200&q=80',
    keyword: '당구장',
  ),
  RecommendCategory(
    id: 'tabletennis',
    title: '탁구',
    subtitle: '2개 장소',
    imageUrl:
    'https://images.unsplash.com/photo-1547347298-4074fc3086f0?auto=format&fit=crop&w=1200&q=80',
    keyword: '탁구장',
  ),
  RecommendCategory(
    id: 'movie',
    title: '영화',
    subtitle: '3개 장소',
    imageUrl:
    'https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?auto=format&fit=crop&w=1200&q=80',
    keyword: '영화관',
  ),
  RecommendCategory(
    id: 'cafe',
    title: '카페',
    subtitle: '3개 장소',
    imageUrl:
    'https://images.unsplash.com/photo-1445116572660-236099ec97a0?auto=format&fit=crop&w=1200&q=80',
    keyword: '카페',
  ),
  RecommendCategory(
    id: 'fitness',
    title: '운동',
    subtitle: '3개 장소',
    imageUrl:
    'https://images.unsplash.com/photo-1517836357463-d25dfeac3438?auto=format&fit=crop&w=1200&q=80',
    keyword: '헬스장',
  ),
];
