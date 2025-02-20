#include <QAbstractItemModelTester>
#include <QQmlApplicationEngine>
#include <QQmlComponent>
#include <QQmlContext>
#include <QQmlEngine>
#include <QVariant>
#include <QtTest>

#include "gadgetlistmodel.h"

class TestGadgetListModel : public QObject
{
private:
  Q_OBJECT

  constexpr static const char* JS_ENGINE_ERROR { "JS Engine has thrown an error" };
  constexpr static int RANDOM_NUMBER { 42 };
  constexpr static int INVALID_ROLE = -1;

  std::unique_ptr<QQmlEngine> engine;
  std::unique_ptr<GadgetListModel> model;

  auto
  makeGetter(const GadgetListModel& model)
  {
    return [&](int idx) {
      auto role = GadgetListModel::Role::DataRole;
      return model.data(model.index(idx), role).toInt();
    };
  };

  static const std::string
  message(const QString& tmpl, const QString& hint)
  {
    return tmpl.arg(hint).toStdString();
  }

public:
  TestGadgetListModel() = default;

private slots:
  void
  initTestCase()
  {
    engine = std::make_unique<QQmlEngine>();
    QQmlComponent component(
      engine.get(),
      "tests", "GadgetListModel",
      QQmlComponent::PreferSynchronous);
    model.reset(dynamic_cast<GadgetListModel*>(component.create()));
    new QAbstractItemModelTester(model.get(), this);
  }

  void
  cleanup ()
  {
    model->clear();
  }

  void
  appendMethodShouldAddItemIntoTheModel()
  {
    QSignalSpy spy(model.get(), &GadgetListModel::rowsInserted);

    model->append(RANDOM_NUMBER);
    QCOMPARE(model->rowCount({}), 1);
    auto variant = model->data(model->index(0), GadgetListModel::Role::DataRole);
    QVERIFY2(variant.isValid(), "The model should have an item");
    auto data = variant.value<int>();
    QCOMPARE(data, RANDOM_NUMBER);

    auto& args = spy.first();
    QCOMPARE(spy.count(), 1);
    QCOMPARE(args.at(1), 0);
    QCOMPARE(args.at(2), 0);
  }

  void
  dataMethodShouldReturnCorrectValueByRole()
  {
    const int DATA = 1;
    model->append(DATA);

    {
      auto data = model->data(model->index(0), GadgetListModel::Role::DisplayRole);
      QVERIFY(data.isValid());
      QCOMPARE(data.userType(), QMetaType::Type::QString);
      QCOMPARE(data.value<QString>(), QString("%1").arg(DATA));
    }
    {
      auto data = model->data(model->index(0), GadgetListModel::Role::DataRole);
      QVERIFY(data.isValid());
      QCOMPARE(data.userType(), QMetaType::Type::Int);
      QCOMPARE(data.value<int>(), DATA);
    }
    {
      auto data = model->data(model->index(0), INVALID_ROLE);
      QVERIFY(!data.isValid());
    }
  }

  void
  setDataMethodShouldSetOnlyDataRole()
  {
    QSignalSpy spy(model.get(), &GadgetListModel::dataChanged);
    const int A = 1, B = 2;
    model->append(A);
    auto get = makeGetter(*model);
    {
      auto isSet = model->setData(model->index(0), B, INVALID_ROLE);
      QVERIFY(!isSet);
      QCOMPARE(get(0), A);
    }
    {
      auto isSet = model->setData(model->index(0), B, GadgetListModel::Role::DisplayRole);
      QVERIFY(!isSet);
      QCOMPARE(get(0), A);
    }
    {
      auto isSet = model->setData(model->index(0), B, GadgetListModel::Role::DataRole);
      QVERIFY(isSet);
      QCOMPARE(get(0), B);
    }
    QCOMPARE(spy.count(), 1);
  }

  void
  setDataMethodShouldNotSetInvalidIndex()
  {
    const int A = 1, B = 2;
    QSignalSpy spy(model.get(), &GadgetListModel::dataChanged);
    model->append(A);
    QVERIFY(!model->setData(model->index(-1), B, GadgetListModel::Role::DataRole));
    QVERIFY(!model->setData(model->index(1), B, GadgetListModel::Role::DataRole));
    QCOMPARE(spy.count(), 0);
  }

  void
  appendListMethodShouldAddItemsIntoTheModel()
  {
    QSignalSpy spy(model.get(), &GadgetListModel::rowsInserted);
    const int A = 1, B = 2, C = 3;
    QVariantList list { A, B, C };

    model->appendList(list);

    auto get = makeGetter(*model);
    QCOMPARE(get(0), A);
    QCOMPARE(get(1), B);
    QCOMPARE(get(2), C);

    auto& args = spy.first();
    QCOMPARE(spy.count(), 1);
    QCOMPARE(args.at(1), 0);
    QCOMPARE(args.at(2), 2);
  }

  void
  removeMethodShouldNotThrowAJsErrorOnAnEmptyModel()
  {
    auto dummyPredicate = engine->evaluate("(value) => false");
    QVERIFY2(!engine->hasError(), JS_ENGINE_ERROR);

    model->remove(dummyPredicate);
    QCOMPARE(engine->hasError(), false);
  }

  void
  removeMethodShouldRemoveAnItemByJSPredicate()
  {
    QSignalSpy spy(model.get(), &GadgetListModel::modelReset);

    model->append(RANDOM_NUMBER);
    QVERIFY2(model->rowCount({}) == 1, "Model should not be empty");
    auto jsExpression = QString("(value) => (value === %1)").arg(RANDOM_NUMBER);
    auto removeFirstCb = engine->evaluate(jsExpression);
    QVERIFY2(!engine->hasError(), JS_ENGINE_ERROR);

    model->remove(removeFirstCb);
    QVERIFY2(model->rowCount({}) == 0, "Model should be empty after removing an item");
    QCOMPARE(spy.count(), 1);
  }

  void
  removeMethodShouldThrowTypeErrorWhenJSPridicateIsNotCallable()
  {
    auto arbitraryValue = engine->evaluate("'not callable random value'");
    QVERIFY2(!engine->hasError(), JS_ENGINE_ERROR);

    model->remove(arbitraryValue);
    auto error = engine->catchError();
    QVERIFY2(error.errorType() == QJSValue::TypeError, "Should throw a TypeError");
  }

  void
  dataMethodShouldReturnRightItemByIndex()
  {
    model->append(1);
    model->append(2);
    model->append(3);
    auto test = [&](auto expectedValue, int index, GadgetListModel::Role role) {
      auto item = model->data(model->index(index, 0, {}), role);
      auto value = item.value<decltype(expectedValue)>();
      QCOMPARE(value, expectedValue);
    };

    test(QString("1"), 0, GadgetListModel::Role::DisplayRole);
    test(QString("2"), 1, GadgetListModel::Role::DisplayRole);
    test(QString("3"), 2, GadgetListModel::Role::DisplayRole);
    test(1, 0, GadgetListModel::Role::DataRole);
    test(2, 1, GadgetListModel::Role::DataRole);
    test(3, 2, GadgetListModel::Role::DataRole);
  }

  void
  toArrayMethodShouldReturnEmptyArrayWhenModelIsEmpty()
  {
    auto jsArray = model->toArray();
    auto array = engine->fromScriptValue<QJsonValue>(jsArray).toArray();
    QCOMPARE(array.size(), 0);
  }

  void
  toArrayMethodShouldReturnCorrespondingJSArray()
  {
    model->append("a");
    model->append("b");
    model->append("c");

    auto jsArray = model->toArray();
    auto array = engine->fromScriptValue<QJsonValue>(jsArray).toArray();
    QCOMPARE(array.size(), 3);
    QCOMPARE(array.at(0).toString(), "a");
    QCOMPARE(array.at(1).toString(), "b");
    QCOMPARE(array.at(2).toString(), "c");
  }

  void
  clearMethodShouldClearTheModel()
  {
    QSignalSpy spy(model.get(), &GadgetListModel::modelReset);

    QCOMPARE(model->rowCount({}), 0);
    model->append("42");
    QCOMPARE(model->rowCount({}), 1);

    model->clear();
    QCOMPARE(model->rowCount({}), 0);
    QCOMPARE(spy.count(), 1);
  }

  void
  findIndexMethodShouldReturnInvalidIndexWhenModelIsEmpty()
  {
    auto dummyPredicate = engine->evaluate("(value) => false");
    QVERIFY2(!engine->hasError(), JS_ENGINE_ERROR);

    auto idx = model->findIndex(dummyPredicate);
    QCOMPARE(idx.isValid(), false);
  }

  void
  findIndexMethodShouldFindAnIndexByUsingAPredicate()
  {
    model->append("a");
    model->append("b");
    model->append("c");
    auto predicate = engine->evaluate("(value) => value === 'b'");
    QVERIFY2(!engine->hasError(), JS_ENGINE_ERROR);

    auto idx = model->findIndex(predicate);
    QCOMPARE(idx.row(), 1);
  }

  void
  removeRowsMethodShouldReturnValidResult()
  {
    QSignalSpy spy(model.get(), &GadgetListModel::rowsRemoved);

    QVERIFY2(!model->removeRows(0, 0, {}), "The empty model should return false");
    QVERIFY2(!model->removeRows(-1, 0, {}), "Index can't be a negative number (empty)");
    QVERIFY2(!model->removeRows(0, -1, {}), "Count can't be a negative number (empty)");
    QVERIFY2(!model->removeRows(1, 0, {}), "Index can't be more than size of the model (empty)");
    QCOMPARE(spy.count(), 0);

    model->append(1);
    model->append(2);
    QVERIFY2(!model->removeRows(-1, 0, {}), "Index can't be a negative number (filled)");
    QVERIFY2(!model->removeRows(0, -1, {}), "Count can't be a negative number (filled)");
    QVERIFY2(!model->removeRows(3, 0, {}), "Index can't be more than size of the model (filled)");
    QCOMPARE(model->rowCount({}), 2);
    QCOMPARE(spy.count(), 0);

    QVERIFY2(model->removeRows(0, 3, {}), "Can remove items when count is more than the model's size (filled)");
    QCOMPARE(model->rowCount({}), 0);
    auto& args = spy.first();
    QCOMPARE(spy.count(), 1);
    QCOMPARE(args.at(1), 0);
    QCOMPARE(args.at(2), 1);
  }

  void
  removeRowsMethodSouldRemoveRowsByIndex()
  {
    QSignalSpy spy(model.get(), &GadgetListModel::rowsRemoved);
    model->append(1);
    model->append(2);
    model->append(3);
    model->append(4);

    auto result = model->removeRows(1, 2, {});
    QVERIFY(result);
    auto get = makeGetter(*model);
    QCOMPARE(model->rowCount({}), 2);
    QCOMPARE(get(0), 1);
    QCOMPARE(get(1), 4);

    auto& args = spy.first();
    QCOMPARE(spy.count(), 1);
    QCOMPARE(args.at(1), 1);
    QCOMPARE(args.at(2), 2);
  }
};

QTEST_MAIN(TestGadgetListModel)
#include "gadgetlistmodel.test.moc"
