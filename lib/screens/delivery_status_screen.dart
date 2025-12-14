import 'package:flutter/material.dart';
import '../services/order_service.dart';
import '../models/order.dart';

/// 배달 상황 화면
class DeliveryStatusScreen extends StatelessWidget {
  final OrderService orderService;

  const DeliveryStatusScreen({
    super.key,
    required this.orderService,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: orderService,
      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('배달 상황'),
          ),
          body: orderService.orders.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.local_shipping_outlined,
                        size: 100,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '배달 중인 주문이 없습니다',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: orderService.orders.length,
                  itemBuilder: (context, index) {
                    final order = orderService.orders[index];
                    return _OrderCard(order: order);
                  },
                ),
        );
      },
    );
  }
}

/// 개별 주문 카드
class _OrderCard extends StatelessWidget {
  final Order order;

  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 주문 정보 헤더
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '주문번호: ${order.id.substring(order.id.length - 6)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(order.status),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        order.statusIcon,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        order.statusText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _formatDate(order.orderDate),
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),

            // 배달 진행 상황
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _StatusStep(
                      icon: '📦',
                      label: '제품 준비',
                      isActive: order.status.index >= 0,
                      isCompleted: order.status.index > 0,
                    ),
                    Expanded(
                      child: Container(
                        height: 2,
                        color: order.status.index > 0
                            ? Colors.orange[700]
                            : Colors.grey[300],
                      ),
                    ),
                    _StatusStep(
                      icon: '🚚',
                      label: '배달 준비',
                      isActive: order.status.index >= 1,
                      isCompleted: order.status.index > 1,
                    ),
                    Expanded(
                      child: Container(
                        height: 2,
                        color: order.status.index > 1
                            ? Colors.orange[700]
                            : Colors.grey[300],
                      ),
                    ),
                    _StatusStep(
                      icon: '🚛',
                      label: '배달 중',
                      isActive: order.status.index >= 2,
                      isCompleted: order.status.index > 2,
                    ),
                    Expanded(
                      child: Container(
                        height: 2,
                        color: order.status.index > 2
                            ? Colors.orange[700]
                            : Colors.grey[300],
                      ),
                    ),
                    _StatusStep(
                      icon: '✅',
                      label: '도착',
                      isActive: order.status.index >= 3,
                      isCompleted: order.status.index >= 3,
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),

            // 주문 상품 목록
            const Text(
              '주문 상품',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            ...order.items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.orange[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            item.product.imageUrl,
                            style: const TextStyle(fontSize: 24),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.product.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              '${item.quantity}개',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${item.totalPrice.toStringAsFixed(0)}원',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                )),
            const SizedBox(height: 8),
            const Divider(),
            const SizedBox(height: 8),

            // 총 금액
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '총 결제 금액',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${order.totalPrice.toStringAsFixed(0)}원',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange[700],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(DeliveryStatus status) {
    switch (status) {
      case DeliveryStatus.preparing:
        return Colors.blue;
      case DeliveryStatus.readyToShip:
        return Colors.orange;
      case DeliveryStatus.inTransit:
        return Colors.purple;
      case DeliveryStatus.delivered:
        return Colors.green;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}

/// 배달 진행 단계 위젯
class _StatusStep extends StatelessWidget {
  final String icon;
  final String label;
  final bool isActive;
  final bool isCompleted;

  const _StatusStep({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: isActive
                ? Colors.orange[700]
                : Colors.grey[300],
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              icon,
              style: const TextStyle(fontSize: 24),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: isActive ? Colors.black87 : Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
