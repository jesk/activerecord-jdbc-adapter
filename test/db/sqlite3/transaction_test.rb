require 'db/sqlite3'
require 'transaction'

class SQLite3TransactionTest < Test::Unit::TestCase
  include TransactionTestMethods

  # @override
  def test_supports_transaction_isolation
    assert ActiveRecord::Base.connection.supports_transaction_isolation?
    # NOTE: adapter tell us it supports but JDBC meta-data API returns false ?!
    #assert ActiveRecord::Base.connection.supports_transaction_isolation?(:read_uncommitted)
    assert ActiveRecord::Base.connection.supports_transaction_isolation?(:serializable)
  end

  # supports only TRANSACTION_SERIALIZABLE and TRANSACTION_READ_UNCOMMITTED

  # @override
  def test_transaction_isolation_read_committed
    assert ! ActiveRecord::Base.connection.supports_transaction_isolation?(:read_committed)

    assert_raise ActiveRecord::TransactionIsolationError do
      super
    end
  end if Test::Unit::TestCase.ar_version('4.0')

  # @override
  def test_transaction_isolation_repeatable_read
    assert ! ActiveRecord::Base.connection.supports_transaction_isolation?(:repeatable_read)

    assert_raise ActiveRecord::TransactionIsolationError do
      super
    end
  end if Test::Unit::TestCase.ar_version('4.0')

  def test_transaction_isolation_read_uncommitted
    Entry.transaction(:isolation => :read_uncommitted) do
      assert_equal 0, Entry.count
      Entry.create # Entry2.create
      assert_equal 1, Entry.count
    end
  end if Test::Unit::TestCase.ar_version('4.0')

  def test_supports_savepoints
    assert_true ActiveRecord::Base.connection.supports_savepoints?
  end

end
