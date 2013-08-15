#require 'thread'

class PriorityQueue
  def initialize
    clear
  end

  def clear
    @queues = {}
  end

  def [](value)
    @queues[value] ||= Queue.new
  end

  def priorities
    @queues.keys.sort
  end

  def shift
    priorities.each do |key|
      if not self[key].empty?
        return self[key].shift(true)
      else
        @queues.delete(key)
      end
    end
    nil
  end
  
  def size
    @queues.values.inject(0) do |size, queue|
      size + queue.size
    end
  end

  def empty?
    @queues.all? {|priority, queue| queue.empty?}
  end
end
