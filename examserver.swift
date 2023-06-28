//
//  main.swift
//  exam_server_ves.cpp
//
//  Created by Вика Вертаева on 28.06.2023.



//
//main.spp
//
//

#include <QCoreApplication>
#include "mytcpserver.h"
 
int main(int argc, char *argv[])
{
    QCoreApplication a(argc, argv);
    MyTcpServer myserv;
    return a.exec();
}

//
//
//
//
//mytspserver.h


#ifndef MYTCPSERVER_H
#define MYTCPSERVER_H
 
#include <QObject>
#include <QTcpServer>
#include <QTcpSocket>
#include <QtNetwork>
#include <QByteArray>
#include <QDebug>
 
class MyTcpServer : public QObject //создание класса
{
    Q_OBJECT
public:
    explicit MyTcpServer(QObject *parent = nullptr);
    ~MyTcpServer(); // деструктор по умолчанию

public slots:
    void slotNewConnection(); //тут будет новое подключение клиента
    void slotClientDisconnected(); //тут мы его отключаем
    void slotServerRead(); //читаем данные с сервера
private:
    QTcpServer * mTcpServer; //указатьль на класс qtspserver
    QList<QTcpSocket*> mTcpSockets; // здесь будет список наших сокетов
};
 
#endif // MYTCPSERVER_H

//
//
//
//
//
//mytspserver.pro
//
//просто копируем из гугл документа
QT -= gui
QT += network #Для работы с сетью
CONFIG += c++11 console
CONFIG -= app_bundle
# The following define makes your compiler emit warnings if you use# any Qt feature that has been marked deprecated (the exact warnings
# depend on your compiler). Please consult the documentation of the# deprecated API in order to know how to port your code away from it.
DEFINES += QT_DEPRECATED_WARNINGS
# You can also make your code fail to compile if it uses deprecated APIs.# In order to do so, uncomment the following line.
# You can also select to disable deprecated APIs only up to a certain version of Qt.#DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0
SOURCES += \
    main.cpp \    mytcpserver.cpp
# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/binelse: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target
HEADERS += \    mytcpserver.h

//
//
//
//
//
//
//mytspserver.cpp
//
//
#include "mytcpserver.h" // подключение заголовочного файла mytcpserver.h
#include <QDebug> // подключение заголовочного файла QDebug
#include <QCoreApplication> // подключение заголовочного файла QCoreApplication
 
MyTcpServer::~MyTcpServer() // деструктор класса MyTcpServer
{
    mTcpServer->close(); // закрытие сервера TCP
}
 
MyTcpServer::MyTcpServer(QObject *parent) : QObject(parent){ // конструктор класса MyTcpServer
    mTcpServer = new QTcpServer(this); // создание нового объекта QTcpServer
    connect(mTcpServer, &QTcpServer::newConnection, this, &MyTcpServer::slotNewConnection); // подключение сигнала newConnection к слоту slotNewConnection
 
    if(!mTcpServer->listen(QHostAddress::Any, 33333)){ // запуск сервера на прослушивание всех доступных адресов на порту 33333
        qDebug() << "server is not started"; // вывод сообщения, если сервер не удалось запустить
    } else {
        qDebug() << "server is started"; // вывод сообщения, если сервер успешно запущен
    }
}
 
void MyTcpServer::slotNewConnection(){ // слот для нового подключения клиента
    QTcpSocket* socket = mTcpServer->nextPendingConnection(); // получение следующего ожидающего подключения сокета
    mTcpSockets.append(socket); // добавление сокета в список
    socket->write("Hello, World!!! I am echo server!\r\n"); // отправка приветственного сообщения клиенту
    connect(socket, &QTcpSocket::readyRead, this, &MyTcpServer::slotServerRead); // подключение сигнала readyRead к слоту slotServerRead
    connect(socket, &QTcpSocket::disconnected, this, &MyTcpServer::slotClientDisconnected); // подключение сигнала disconnected к слоту slotClientDisconnected
}
 
void MyTcpServer::slotServerRead(){ // слот для чтения данных от клиента
    QTcpSocket* senderSocket = qobject_cast<QTcpSocket*>(sender()); // получение сокета отправителя
    QByteArray array = senderSocket->readAll(); // чтение всех доступных данных из сокета отправителя
    QString message = QString(array); // преобразование массива байт в строку
    QString newMessage; // создание новой строки для измененного сообщения
    for (int i = 0; i < message.length(); i++) { // цикл по всем символам в сообщении
        newMessage.append(message[i]); // добавление символа в новое сообщение
        if ((i + 1) % 3 == 0) { // если символ является третьим символом в группе
            newMessage.append(" "); // добавление пробела в новое сообщение
            newMessage.append(message[i]); // добавление символа в новое сообщение
        }
    }
    for (int j = 0; j < mTcpSockets.length(); j++) { // цикл по всем сокетам в списке
        if (mTcpSockets[j] != senderSocket) { // если сокет не является отправителем
            mTcpSockets[j]->write(newMessage.toUtf8()); // отправка измененного сообщения клиенту
        }
    }
}
 
void MyTcpServer::slotClientDisconnected(){ // слот для отключения клиента
    QTcpSocket* senderSocket = qobject_cast<QTcpSocket*>(sender()); // получение сокета отправителя
    mTcpSockets.removeOne(senderSocket); // удаление сокета из списка
    senderSocket->close(); // закрытие сокета
}
//
//
//
//
//
//

