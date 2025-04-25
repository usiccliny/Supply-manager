package com.example.supply_manager_api.service;

import com.example.supply_manager_api.dto.OrderDetailRequestDTO;
import com.example.supply_manager_api.dto.OrderRequestDTO;
import com.example.supply_manager_api.model.*;
import com.example.supply_manager_api.repository.*;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.io.Console;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Service
public class OrderServ {

    private final OrderRep orderRepository;
    private final OrderDetailRepository orderDetailRepository;
    private final UserRepository userRepository;
    private final PaymentMethodRepository paymentMethodRepository;
    private final ProductRepository productRepository;
    private final SupplierRep supplierRepository;

    public OrderServ(OrderRep orderRepository,
                        OrderDetailRepository orderDetailRepository,
                        UserRepository userRepository,
                        PaymentMethodRepository paymentMethodRepository,
                        ProductRepository productRepository,
                        SupplierRep supplierRepository) {
        this.orderRepository = orderRepository;
        this.orderDetailRepository = orderDetailRepository;
        this.userRepository = userRepository;
        this.paymentMethodRepository = paymentMethodRepository;
        this.productRepository = productRepository;
        this.supplierRepository = supplierRepository;
    }

    @Transactional
    public void createOrder(OrderRequestDTO orderRequestDTO) {
        User user = userRepository.findById(orderRequestDTO.getUserId())
                .orElseThrow(() -> new RuntimeException("User not found"));

        PaymentMethod paymentMethod = paymentMethodRepository.findById(orderRequestDTO.getPaymentMethodId())
                .orElseThrow(() -> new RuntimeException("Payment method not found"));

        Order order = new Order();
        order.setUser(user);
        order.setOrderStatusId(1L);
        order.setPaymentMethod(paymentMethod);
        order.setOrderDate(LocalDateTime.now());
        order.setTotalAmount(orderRequestDTO.getTotalAmount());
        order.setShippingAddress(orderRequestDTO.getShippingAddress());
        order.setBillingAddress(orderRequestDTO.getBillingAddress());
        order.setTrackingNumber(generateTrackingNumber());
        order.setDateCreated(LocalDateTime.now());
        order.setDateModified(LocalDateTime.now());
        order.setObsolete(false);

        Order savedOrder = orderRepository.save(order);

        List<OrderDetail> orderDetails = new ArrayList<>();
        for (OrderDetailRequestDTO detailDTO : orderRequestDTO.getOrderDetails()) {
            Product product = productRepository.findByIdAndObsoleteFalse(detailDTO.getProductId())
                    .orElseThrow(() -> new RuntimeException("Product not found"));
            Supplier supplier = supplierRepository.findBySupplierIdAndObsoleteFalse(detailDTO.getSupplierId())
                    .orElseThrow(() -> new RuntimeException("Supplier not found"));

            OrderDetail orderDetail = new OrderDetail();
            orderDetail.setOrderId(savedOrder.getId());
            orderDetail.setOrderVersionId(savedOrder.getVersionId());
            orderDetail.setProduct(product);
            orderDetail.setSupplier(supplier);
            orderDetail.setQuantity(detailDTO.getQuantity());
            orderDetail.setDateCreated(LocalDateTime.now());
            orderDetail.setDateModified(LocalDateTime.now());
            orderDetail.setObsolete(false);

            orderDetails.add(orderDetail);
        }

        orderDetailRepository.saveAll(orderDetails);
    }


    private String generateTrackingNumber() {
        return "TRK-" + System.currentTimeMillis();
    }
}