package com.booleanuk.TodoApp.models;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name = "todos")
public class Todo {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int id;

    @Column
    private String title;

    @Column
    private boolean completed;

    public Todo(int id){
        this.id = id;
    }

    public Todo(String title) {
        this.title = title;
        this.completed = false;
    }
    public Todo(String title, boolean completed) {
        this.title = title;
        this.completed = completed;
    }
}
