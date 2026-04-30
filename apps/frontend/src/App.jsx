import { useState, useEffect } from 'react';

export default function App() {
  const [todos, setTodos] = useState([]);
  const [input, setInput] = useState('');
  const [error, setError] = useState(null);

  useEffect(() => {
    fetchTodos();
  }, []);

  async function fetchTodos() {
    try {
      const res = await fetch('/api/todos');
      if (!res.ok) throw new Error('Failed to fetch todos');
      setTodos(await res.json());
    } catch (err) {
      setError(err.message);
    }
  }

  async function addTodo(e) {
    e.preventDefault();
    if (!input.trim()) return;
    try {
      const res = await fetch('/api/todos', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ title: input.trim() }),
      });
      if (!res.ok) throw new Error('Failed to create todo');
      setInput('');
      await fetchTodos();
    } catch (err) {
      setError(err.message);
    }
  }

  async function toggleTodo(todo) {
    try {
      const res = await fetch(`/api/todos/${todo.id}`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ completed: !todo.completed }),
      });
      if (!res.ok) throw new Error('Failed to update todo');
      await fetchTodos();
    } catch (err) {
      setError(err.message);
    }
  }

  async function deleteTodo(id) {
    try {
      const res = await fetch(`/api/todos/${id}`, { method: 'DELETE' });
      if (!res.ok) throw new Error('Failed to delete todo');
      await fetchTodos();
    } catch (err) {
      setError(err.message);
    }
  }

  return (
    <div className="container">
      <h1>Todos</h1>

      {error && (
        <p className="error" onClick={() => setError(null)}>
          {error} (click to dismiss)
        </p>
      )}

      <form onSubmit={addTodo} className="add-form">
        <input
          type="text"
          placeholder="What needs to be done?"
          value={input}
          onChange={(e) => setInput(e.target.value)}
        />
        <button type="submit">Add</button>
      </form>

      <ul className="todo-list">
        {todos.map((todo) => (
          <li key={todo.id} className={todo.completed ? 'completed' : ''}>
            <span onClick={() => toggleTodo(todo)}>{todo.title}</span>
            <button onClick={() => deleteTodo(todo.id)}>✕</button>
          </li>
        ))}
      </ul>

      {todos.length === 0 && <p className="empty">No todos yet.</p>}
    </div>
  );
}
