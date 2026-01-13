class RecommendCategory {
  RecommendCategory({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.keyword,
  });

  final String id;
  final String title;
  final String imageUrl;
  final String keyword;
}

final recommendCategories = <RecommendCategory>[
  RecommendCategory(
    id: '보드게임',
    title: '보드게임',
    imageUrl:
    'https://images.unsplash.com/photo-1610890716171-6b1bb98ffd09?auto=format&fit=crop&w=1200&q=80',
    keyword: '보드게임',
  ),
  RecommendCategory(
    id: '볼링',
    title: '볼링',
    imageUrl:
    'https://images.unsplash.com/photo-1521537634581-0dced2fee2ef?auto=format&fit=crop&w=1200&q=80',
    keyword: '볼링장',
  ),
  RecommendCategory(
    id: '게임',
    title: 'PC방',
    imageUrl:
    'https://images.unsplash.com/photo-1527443154391-507e9dc6c5cc?auto=format&fit=crop&w=1200&q=80',
    keyword: 'PC방',
  ),
  RecommendCategory(
    id: '당구',
    title: '당구',
    imageUrl:
    'https://images.unsplash.com/photo-1529692236671-f1f6cf9683ba?auto=format&fit=crop&w=1200&q=80',
    keyword: '당구장',
  ),
  RecommendCategory(
    id: '탁구',
    title: '탁구',
    imageUrl:
    'https://images.unsplash.com/photo-1547347298-4074fc3086f0?auto=format&fit=crop&w=1200&q=80',
    keyword: '탁구장',
  ),
  RecommendCategory(
    id: '영화 보기',
    title: '영화',
    imageUrl:
    'https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?auto=format&fit=crop&w=1200&q=80',
    keyword: '영화관',
  ),
  RecommendCategory(
    id: '카페 가기',
    title: '카페',
    imageUrl:
    'https://images.unsplash.com/photo-1445116572660-236099ec97a0?auto=format&fit=crop&w=1200&q=80',
    keyword: '카페',
  ),
  RecommendCategory(
    id: '운동',
    title: '운동',
    imageUrl:
    'https://images.unsplash.com/photo-1517836357463-d25dfeac3438?auto=format&fit=crop&w=1200&q=80',
    keyword: '헬스장',
  ),
  RecommendCategory(
    id: '노래방 가기',
    title: '노래방',
    imageUrl:
    'https://unsplash.com/photos/Gi6-m_t_W-E/download?force=true&w=1920',
    keyword: '노래방',
  ),
];
