package com.booleanuk.TodoApp.controllers;

import com.booleanuk.TodoApp.models.Todo;
import com.booleanuk.TodoApp.repositories.TodoRepository;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;
import org.springframework.web.servlet.config.annotation.EnableWebMvc;

import java.util.List;

@CrossOrigin
@RestController
@EnableWebMvc
@RequestMapping("todos")
public class TodoController {
    private final TodoRepository todoRepository;

    public TodoController(TodoRepository repository) {
        this.todoRepository = repository;
    }

    @GetMapping
    public ResponseEntity<List<Todo>> getAllTodos() {
        return ResponseEntity.ok(this.todoRepository.findAll());
    }

    @GetMapping("/{id}")
    public ResponseEntity<Todo> getOneTodo(@PathVariable int id) {
        Todo todo = this.todoRepository.findById(id).orElseThrow(
                () -> new ResponseStatusException(HttpStatus.NOT_FOUND, "No todo with that id exists"));
        return ResponseEntity.ok(todo);
    }

    @PostMapping
    public ResponseEntity<Todo> createTodo(@RequestBody Todo todo) {
        Todo newTodo = null;
        try {
            newTodo = this.todoRepository.save(todo);
        } catch (Exception e) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "No todo created the server said: " + e);
        }
        return new ResponseEntity<>(newTodo, HttpStatus.CREATED);
    }

    @PutMapping("/{id}")
    public ResponseEntity<Todo> updateTodo(@PathVariable int id, @RequestBody Todo todo) {
        Todo todoToUpdate = this.todoRepository.findById(id).orElseThrow(
                () -> new ResponseStatusException(HttpStatus.NOT_FOUND, "No todo with that id exists"));
        todoToUpdate.setCompleted(todo.isCompleted());
        todoToUpdate.setTitle(todo.getTitle());
        try {
            todoToUpdate = this.todoRepository.save(todoToUpdate);
        } catch (Exception e) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "No todo created the server said: " + e);
        }
        return new ResponseEntity<>(todoToUpdate, HttpStatus.CREATED);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Todo> deleteTodo(@PathVariable int id) {
        Todo todoToDelete = this.todoRepository.findById(id).orElseThrow(
                () -> new ResponseStatusException(HttpStatus.NOT_FOUND, "No todo with that id exists"));
        this.todoRepository.delete(todoToDelete);
        return ResponseEntity.ok(todoToDelete);
    }
 }
