import 'package:flutter/material.dart';
import '../models/allergen.dart';

/// 사용자의 알레르기 프로필을 설정하는 화면
/// 
/// StatefulWidget: 상태가 변경될 수 있는 위젯
/// (사용자가 알레르기를 선택/해제하면 화면이 업데이트되어야 하므로 Stateful 사용)
class AllergyProfileScreen extends StatefulWidget {
  /// 현재 선택된 알레르기 ID 목록
  final List<String> selectedAllergens;
  
  /// 알레르기가 변경될 때 호출되는 콜백 함수
  final Function(List<String>) onAllergensChanged;

  const AllergyProfileScreen({
    super.key,
    required this.selectedAllergens,
    required this.onAllergensChanged,
  });

  @override
  State<AllergyProfileScreen> createState() => _AllergyProfileScreenState();
}

/// AllergyProfileScreen의 상태를 관리하는 클래스
class _AllergyProfileScreenState extends State<AllergyProfileScreen> {
  /// 현재 선택된 알레르기를 저장하는 로컬 리스트
  /// late: 나중에 초기화됨을 나타냄
  late List<String> _selectedAllergens;

  @override
  void initState() {
    super.initState();
    // 위젯이 생성될 때 부모로부터 받은 알레르기 목록을 복사
    _selectedAllergens = List.from(widget.selectedAllergens);
  }

  /// 알레르기 선택/해제를 처리하는 함수
  void _toggleAllergen(String allergenId) {
    setState(() {
      // setState를 호출하면 화면이 다시 그려집니다
      if (_selectedAllergens.contains(allergenId)) {
        // 이미 선택되어 있으면 제거
        _selectedAllergens.remove(allergenId);
      } else {
        // 선택되어 있지 않으면 추가
        _selectedAllergens.add(allergenId);
      }
    });
  }

  /// 저장 버튼을 눌렀을 때 호출되는 함수
  void _saveProfile() {
    // 부모 위젯에 변경사항을 전달
    widget.onAllergensChanged(_selectedAllergens);
    // 이전 화면으로 돌아가기
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /// AppBar: 화면 상단의 제목 표시줄
      appBar: AppBar(
        title: const Text('내 알레르기 프로필'),
        backgroundColor: Colors.orange[700],
      ),
      body: Column(
        children: [
          /// 안내 메시지
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Colors.orange[50],
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.orange),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '알레르기가 있는 항목을 선택해주세요.\n안전한 제품만 추천해드립니다.',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
          
          /// 알레르기 목록
          Expanded(
            child: ListView.builder(
              /// Allergen.commonAllergens의 개수만큼 항목 생성
              itemCount: Allergen.commonAllergens.length,
              itemBuilder: (context, index) {
                final allergen = Allergen.commonAllergens[index];
                final isSelected = _selectedAllergens.contains(allergen.id);

                /// Card: 그림자 효과가 있는 카드 위젯
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  elevation: 2,
                  child: ListTile(
                    /// 왼쪽에 아이콘 표시
                    leading: CircleAvatar(
                      backgroundColor: isSelected 
                          ? Colors.red[100] 
                          : Colors.grey[200],
                      child: Text(
                        allergen.icon,
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                    /// 알레르기 이름
                    title: Text(
                      allergen.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    /// 영문 이름
                    subtitle: Text(allergen.nameEn),
                    /// 오른쪽에 체크박스
                    trailing: Checkbox(
                      value: isSelected,
                      onChanged: (bool? value) {
                        _toggleAllergen(allergen.id);
                      },
                      activeColor: Colors.red,
                    ),
                    /// 항목을 탭해도 선택/해제 가능
                    onTap: () => _toggleAllergen(allergen.id),
                  ),
                );
              },
            ),
          ),
          
          /// 하단 저장 버튼
          Container(
            padding: const EdgeInsets.all(16.0),
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saveProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange[700],
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: Text(
                '저장하기 (${_selectedAllergens.length}개 선택됨)',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
